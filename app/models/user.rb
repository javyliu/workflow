class User < ActiveRecord::Base
  self.primary_key = 'uid'
  belongs_to :dept, class_name: 'Department', foreign_key: :dept_code,touch: true
  has_many :checkinouts
  #昨天签到用户，用于发送日常邮件中的 includes
  has_one :yesterday_checkin,-> {where(rec_date: (User.query_date || Date.yesterday).to_s)},class_name: "Checkinout"
  has_many :year_infos
  #假期及ab分基础数据，用于计算用户剩余年假
  has_one :last_year_info,-> {where(year: OaConfig.setting(:end_year_time)[0..3]) },class_name: "YearInfo"
  has_many :journals
  #从本年度计考勤之日起的异常考勤，用于计算每天的剩余年假
  has_many :year_journals, -> { where(["update_date > ?",OaConfig.setting(:end_year_time)]).select("id,user_id,check_type,sum(dval) dval").group(:user_id,:check_type) },class_name: "Journal"

  has_many :episodes
  has_many :yes_holidays, -> {where(["start_date <= :yesd and end_date >= :yesd ",yesd: (User.query_date || Date.yesterday).to_s])},through: :episodes,source: :holiday

  before_save :delete_caches


  #for login
  has_secure_password # validations: false

  ROLES = %w[admin manager department_manager badman]

  class << self
    attr_accessor :query_date
  end

  #每日发送前一天部门的考勤邮件，如果昨天是工作日 ，则发送每个部门的考勤邮件，如果是非工作日 ，则只发送有考勤异常部门的邮件
  def self.leaders_by_date(date)
    if SpecDay.workday?(date: date)
       User.cached_leaders
    else
      y_checkin_uids = Checkinout.where(rec_date: date.to_s).pluck(:user_id)
      leaders = User.cached_leaders
      y_checkin_uids.compact.each do |uid|
        leaders.each do |item|
          item.push(uid) if item[2].include?(uid)
        end
      end
      leaders.collect { |leader_user_id,rule_id,_,*checkin_uids| [leader_user_id,rule_id,checkin_uids] }
    end
  end

  def roles=(*_roles)
    self.role_group = (_roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    @roles ||= ROLES.reject { |r| ((self.role_group || 0) & 2**ROLES.index(r)).zero? }
  end

  def role?(role)
    roles.include? role.to_s
  end

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

  def email_name
    @email_name ||= %("#{self.user_name}" <#{self.email}>)
  end

  #for the cookie user
  def remember_token?
    remember_token_expires_at && Time.now < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_until 2.weeks.from_now
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token  = encrypt("#{self.user_name}--#{remember_token_expires_at}")
    save :validate => false
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save :validate => false
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, Time.now.to_s)
  end

  def cache_dept
    @cache_dept ||= self.class.cache_departments.detect { |e| e.uid == self.id }
    if self.role?("admin")
      @cache_dept.depts = self.class.cache_departments.inject([]) { |col,e| col << e.depts  }.flatten(1)
    end
    @cache_dept
  end

  def self.cache_departments
    Rails.cache.fetch(:departments) do
      self.find_by_sql("select mgr_code uid,GROUP_CONCAT(code,' ',name) depts from departments  GROUP BY mgr_code ").map { |e| e.depts = e.depts.split(",").map { |item| item.split($\) };e}
    end
  end

  private

  def delete_caches
    Sidekiq.redis do |_redis|
      _redis.del("leaders_data")
    end
    Rails.cache.delete(:departments)
  end
end
