class User < ActiveRecord::Base
  self.primary_key = 'uid'
  belongs_to :dept, class_name: 'Department', foreign_key: :dept_code#,touch: true
  has_many :checkinouts
  #昨天签到用户，用于发送日常邮件中的 includes
  has_one :yesterday_checkin,-> {where(rec_date: (User.query_date || Date.yesterday).to_s)},class_name: "Checkinout"
  has_many :year_infos
  #假期及ab分基础数据，用于计算用户剩余年假
  has_one :last_year_info,-> {where(year: OaConfig.setting(:end_year_time)[0..3]) },class_name: "YearInfo"
  has_many :journals
  #用户在某一天的已确认异常考勤,用于手动加载防止n+1
  #has_one :journal
  #从本年度计考勤之日起的异常考勤，用于计算每天的剩余年假
  has_many :year_journals, -> { where(["update_date > ?",OaConfig.setting(:end_year_time)]).select("id,user_id,check_type,sum(dval) dval").group(:check_type) },class_name: "Journal"

  has_many :episodes
  #用于在Task#eager_load_from_task方法中手动组装数据，
  has_many :yes_holidays , -> {where(["start_date <= :yesd and end_date >= :yesd ",yesd: (User.query_date || Date.yesterday).to_s])},through: :episodes,source: :holiday

  before_save  -> {self.mgr_code=nil if self.mgr_code.blank? }
  before_save :delete_caches,if: -> {(['expire_date','dept_code','mgr_code','title'] & self.changed).present?}


  #for login
  has_secure_password # validations: false

  ROLES = %w[admin manager department_manager kaoqin_viewer badman]

  class << self
    attr_accessor :query_date
  end

  #当前用户的管理者,去除主管
  #2015-03-24 22:05 javy_liu 貌似不会到主管级，更改为直接find
  def leader_user
    #@leader_user ||= User.find(self.mgr_code.presence || self.dept.mgr_code)
    @leader_user ||= if (_leader_user = User.find(self.mgr_code.present? ? self.mgr_code : self.dept.mgr_code)).title.to_i > 400
                       _leader_user.leader_user
                     else
                       _leader_user
                     end
  end

  #每日发送前一天部门的考勤邮件，如果昨天是工作日 ，则发送每个部门的考勤邮件，如果是非工作日 ，则只发送有考勤异常部门的邮件
  def self.leaders_by_date(date)
    if SpecDay.workday?(date: date)
       User.cached_leaders
    else #非工作日有签到的都是异常考勤
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
    self[:role_group] = (_roles.flatten(1) & ROLES).map{ |r| 2**ROLES.index(r)}.sum
  end

  def roles
    @roles ||= ROLES.reject { |r| ((self.role_group || 0) & 2**ROLES.index(r)).zero? }
  end

  def email_en_name
    @email_en_name ||= self.email[/.*(?=@)/,0]
  end

  #当前用户角色可管理的角色列表
  def managed_roles
    @managed_roles ||= if (_index = ROLES.inject([]) { |sum,r| sum << ROLES.index(r) if ((self.role_group || 0) & 2**ROLES.index(r))>0;sum }.min).nil?
                         []
                       else
                         ROLES.reject {|r| ROLES.index(r) < _index }
                       end
  end

  def roles_cn
    roles.map { |e| I18n.t(e) }
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
    where (a.expire_date is NULL or a.expire_date > '#{Date.today.to_s}') and a.mgr_code is NULL and b.attend_rule_id is not NULL GROUP BY b.`code`
    UNION
    select b.attend_rule_id,a.mgr_code uid,GROUP_CONCAT(a.uid) user_ids from users a INNER JOIN departments b on a.dept_code = b.`code`
    where (a.expire_date is NULL or a.expire_date > '#{Date.today.to_s}') and a.mgr_code is not NULL and b.attend_rule_id is not NULL GROUP BY a.mgr_code;
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

  def pending_tasks
    @pending_tasks ||= Task.user_pending_tasks(self.id)
  end

  def group_pending_tasks
    @gpts ||= self.pending_tasks.try(:group_by) do |item|
      item[0..3]
    end
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

  #当前用户所属部门分组
  def dept_group
    @dept_group ||= case self.dept_code
                  when /^(0104|0105|0106)/ #无倒休部门
                    Department::GroupNoSwitchTime
                  when /^(0102|0103)/ #ab 分部门
                    Department::GroupAB
                  else
                    Department::GroupSwitchTime #倒休部门
                  end
  end

  #当前用户可用 check_type
  #用于异常考勤搜索页面显示
  def check_types
    @check_types ||= Journal::CheckType.find_all{|item| !item[1].in?(self.dept_group[3])}
  end

  #当前用户可管理的部门列表
  def cache_dept
    #@cache_dept ||= self.class.cache_departments.detect { |e| e.uid == self.id }
    #if self.role?("admin") || self.role?("manager")
    #  @cache_dept.depts = Department.cache_all_depts
    #end
    #@cache_dept

    @cache_dept ||= if 11 & self.role_group > 0#self.("admin") || self.role?("manager")
                      OpenStruct.new({uid: self.id,depts: Department.cache_all_depts})
                    else
                      self.class.cache_departments.detect { |e| e.uid == self.id }
                    end

  end

  #根据管理者id进行分组的部门列表
  #{"depts"=>[["掌上飞讯", "01"], ["部门领导", "010599"], ["顾问组", "04"], ["掌上明珠", "02"], ["部门领导", "010399"], ["公司高管", "0201"], ["公司高管", "0101"], ["2014前离职", "03"]], "uid"=>"1002"}
  def self.cache_departments
    Rails.cache.fetch(:departments) do
      self.find_by_sql("select mgr_code uid,GROUP_CONCAT(name,' ',code) depts from departments  GROUP BY mgr_code ").map { |e| e.depts = e.depts.split(",").map { |item| item.split($\) };e}
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
