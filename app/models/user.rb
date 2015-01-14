class User < ActiveRecord::Base
  self.primary_key = 'uid'
  belongs_to :dept, class_name: 'Department', foreign_key: :dept_code,touch: true
  has_many :checkinouts
  #昨天签到用户，用于发送日常邮件中的 includes
  has_one :yesterday_checkin,-> {where(rec_date: Date.yesterday.to_s)},class_name: "Checkinout"
  has_many :year_infos
  #假期及ab分基础数据，用于计算用户剩余年假
  has_one :last_year_info,-> {where(year: OaConfig.setting(:end_year_time)[0..3]) },class_name: "YearInfo"
  has_many :journals
  #从本年度计考勤之日起的异常考勤，用于计算每天的剩余年假
  has_many :year_journals, -> { where(["update_date > ?",OaConfig.setting(:end_year_time)]).select("user_id,check_type,sum(dval) dval").group(:user_id,:check_type) },class_name: "Journal"

  has_many :episodes
  #has_many :approved_episodes, -> {select("episodes.id,episodes.holiday_id,user_id,holidays.name").joins(:holiday).where(["start_date <= :yesd and end_date >= :yesd and approved_by > '0'",yesd: Date.yesterday.to_s])},class_name: "Episode"
  has_many :yes_holidays, -> {where(["start_date <= :yesd and end_date >= :yesd and approved_by > '0'",yesd: Date.yesterday.to_s])},through: :episodes,source: :holiday

  before_save :delete_caches

  def self.cached_leaders
    #return leaders with rule and user_ids like following
    #[["1002", "RuleFlexibalWorkingTime", ["1003", "2177", "1002", "1021", "1004", "2178", "1078", "1551", "1013", "1128", "1178"],...]
    Sidekiq.redis do |_redis|
      leaders_ary = _redis.get("leaders_data")

      if leaders_ary
        leaders_ary = JSON.parse(leaders_ary)
      else
        leaders_ary = User.find_by_sql( <<-heredoc
    select b.attend_rule_id,b.mgr_code uid,GROUP_CONCAT(a.uid) user_ids from users a INNER JOIN departments b on a.dept_code = b.`code`
    where a.expire_date is NULL and a.mgr_code is NULL and b.attend_rule_id is not NULL GROUP BY b.`code`
    UNION
    select b.attend_rule_id,a.mgr_code uid,GROUP_CONCAT(a.uid) user_ids from users a INNER JOIN departments b on a.dept_code = b.`code`
    where a.expire_date is NULL and a.mgr_code is not NULL and b.attend_rule_id is not NULL GROUP BY a.mgr_code;
                                       heredoc
                                      ).group_by(&:uid)
        .map{|k,v| [k,v.first.attend_rule_id,v.inject([]){|uids,item|uids + item.user_ids.split(",")}]}
        _redis.set("leaders_data",leaders_ary)
        leaders_ary
      end
    end
  end

  #get leader's rule data
  def self.leader_data(uid)
    User.cached_leaders.assoc(uid.to_s)
  end

  def leader_data
    @leader_data ||= User.leader_data(self.id)
  end

  #用户所用的考勤规则
  def leader_rule
    @rule ||= AttendRule.find(self.leader_data[1])
  end

  #添加一个任务,每日催缴任务发起的地方
  #hmset {leader_user_id,rule_id:rule_id,checkin_uids: checkin_uids,state:pending,count:0}
  def self.create_task(leader_user_id,rule_id,checkin_uids,date,start:false)
    Sidekiq.redis do |conn|
      task_name = "task:#{date}:#{leader_user_id}"
      conn.hmset(task_name,"rule_id", rule_id,"checkin_uids",checkin_uids.to_json,"state","pending","count",0)
      conn.sadd("task:pendings",task_name) if start
    end
  end

  def self.addend_task(task_name)
    Sidekiq.redis do |conn|
      conn.sadd("task:pendings",task_name) if start
    end
  end

  private

  def delete_caches
    Sidekiq.redis do |_redis|
      _redis.del("leaders_data")
    end
  end
end
