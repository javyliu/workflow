class User < ActiveRecord::Base
  self.primary_key = 'uid'
  belongs_to :department,foreign_key: :dept_code,touch: true
  has_many :checkinouts
  #昨天签到用户，用于发送日常邮件中的 includes
  has_many :yesterday_checkins,-> {where(rec_date: Date.yesterday.to_s)},class_name: "Checkinout"


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
    select b.atten_rule,b.mgr_code uid,GROUP_CONCAT(a.uid) user_ids from users a INNER JOIN departments b on a.dept_code = b.`code`
    where a.expire_date is NULL and a.mgr_code is NULL and b.atten_rule is not NULL GROUP BY b.`code`
    UNION
    select b.atten_rule,a.mgr_code uid,GROUP_CONCAT(a.uid) user_ids from users a INNER JOIN departments b on a.dept_code = b.`code`
    where a.expire_date is NULL and a.mgr_code is not NULL and b.atten_rule is not NULL GROUP BY a.mgr_code;
                                       heredoc
                                      ).group_by(&:uid)
        .map{|k,v| [k,v.first.atten_rule,v.inject([]){|uids,item|uids + item.user_ids.split(",")}]}
        _redis.set("leaders_data",leaders_ary)
        leaders_ary
      end
    end
  end



  private

  def delete_caches
    Sidekiq.redis do |_redis|
      _redis.del("leaders_data")
    end
  end
end
