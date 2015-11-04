class Task
  attr_accessor :type #任务类型
  attr_accessor :date #作务发起日期
  attr_accessor :leader_user_id #任务接收人
  attr_accessor :action_name #处理作务的action名称
  attr_accessor :mid #任务对像id

  SubjectRex = /(\w+):(\w+):([-\d]+)(:(\d+))?/
  Expired = "expired"
  Completed = "completed"
  Pending = "pending"

  #不同类型的确认单对应的邮件方法
  CfmType= [
    ["考勤确认单","F001","kaoqing_users_path"],
    ["申请确认单","F002","episode_path"],
    ["加班确认单","F003","episode_path"],
    ["出差确认单","F004","episode_path"]
  ]
  def to_s
    self.task_name
  end

  #任务类型名称
  def type_name
    CfmType.rassoc(self.type).first
  end

  def initialize(type,leader_user_id,date: nil,mid: nil)
    self.type = type
    self.leader_user_id = leader_user_id
    self.action_name = CfmType.rassoc(type).try(:second)
    self.date = (date || Date.yesterday).to_s
    self.mid = mid
  end

  #从邮件标题初始化一个任务
  def self.init_from_subject(subject)
    return false unless subject.is_utf8?
    type,leader_user_id,date,_,mid = Task::SubjectRex.match(subject).try(:captures)
    if type.blank? || date.blank? || leader_user_id.blank?
      return false
    end
    Task.new(type,leader_user_id,date: date,mid: mid)
  end

  #生成任务名（字符串）
  def self.init_task_name(type,leader_user_id,date:nil,mid: nil)
    mid.nil? ? "#{type}:#{leader_user_id}:#{date.to_s}" : "#{type}:#{leader_user_id}:#{date.to_s}:#{mid}"
  end


  #任务名称
  def task_name
    @task_name ||=  self.mid.nil? ? "#{type}:#{leader_user_id}:#{date.to_s}" : "#{type}:#{leader_user_id}:#{date.to_s}:#{mid}"
  end

  #更新任务的某项值
  def update(key,value)
    Sidekiq.redis do |conn|
      conn.hset(self.task_name,key.to_s,value)
    end
  end

  #催缴任务计数器加1
  def increment!
    Sidekiq.redis do |conn|
      conn.hincrby(self.task_name,"count",1)
    end
  end

  #每日催缴任务
  def self.pending_tasks
    Sidekiq.redis do |conn|
      conn.smembers("task:pendings")
    end
  end

  #某用户的所有未完成任务
  def self.user_pending_tasks(user_id)
    Sidekiq.redis do |conn|
      conn.smembers("task:pendings:#{user_id}")
    end
  end

  #删除用户所有的待处理任务，用于手动清除
  def self.remove_pending_tasks(*user_ids)
    Sidekiq.redis do | conn |
      user_ids.each do |_id|
        conn.del("task:pendings:#{_id}")
      end
    end
  end

  #任务特定值
  def attr_value(key)
    Sidekiq.redis do |conn|
      conn.hget(self.task_name,key.to_s)
    end
  end

  #任务催缴次数
  def count
    self.attr_value("count").to_i
  end

  #任务的内容，hash键值
  def content
    @content ||= Sidekiq.redis do |conn|
      conn.hgetall(self.task_name)
    end
  end

  #是否在催缴任务中
  def exists?
    Sidekiq.redis do |conn|
      conn.sismember("task:pendings",self.task_name)
    end
  end


  #创建任务，task:pendings 用于每日的催缴任务,10次催缴后删除，task:pendings:user_id 用于存储用户的所有任务
  def self.create(*args)#type,leader_user_id,rule_id,checkin_uids,action)
    opts = args.extract_options!
    type,leader_user_id = args
    raise "type is nil" if type.nil? || leader_user_id.nil?
    _task = self.new(type,leader_user_id,date: opts.delete(:date),mid: opts.delete(:mid))
    Sidekiq.redis do |conn|
      conn.hmset(_task.task_name,"state",Task::Pending,"count",0,"date",_task.date,*opts.to_a.flatten(1))
      conn.sadd("task:pendings",_task.task_name)
      conn.sadd("task:pendings:#{_task.leader_user_id}",_task.task_name)
    end
    _task
  end

  #删除任务
  def self.remove(type,leader_user_id,date: nil,all: false)
    _task = self.new(type,leader_user_id,date: date)
    _task.remove(all: all)
  end


  #删除任务
  def remove(all: false)
    Sidekiq.redis do |conn|
      conn.srem("task:pendings",self.task_name)
      conn.srem("task:pendings:#{self.leader_user_id}",self.task_name) if all
    end
  end


  def self.eager_load_from_task(task,leader_user: nil,rule: nil)
    leader_user ||= User.find(task.leader_user_id).decorate
    uids ||= leader_user.uids || leader_user.leader_data.try(:last)
    rule ||= AttendRule.find(leader_user.leader_data[1])

    leader_user.ref_cmd[0] = 0
    users = User.where(uid: uids).includes(:last_year_info,:dept).decorate

    date_checkins = Checkinout.where(user_id: uids,rec_date: task.date).to_a

    #非示通过的
    yes_holidays = Holiday.select("holidays.id holiday_id,holidays.name,episodes.user_id,episodes.id").joins(:episodes).where(["user_id in (:users) and state <> 2 and date(start_date) <= :yesd and end_date >= :yesd ",yesd: task.date,users: uids]).to_a

    year_journals = Journal.grouped_journals.where(["user_id in (?)",uids]).to_a

    journals = task.date.to_s < Date.today.to_s ? Journal.where(["user_id in (?) and update_date = ?",uids,task.date]).to_a : []

    users.each do |item|
      #manually preload yesterday_checkin and yes_holiday
      ass = item.association(:yesterday_checkin)
      ass.loaded!
      ass.target = date_checkins.detect{|_item| _item.user_id == item.id }

      ass = item.association(:yes_holidays)
      ass.loaded!
      ass.target.concat(
        yes_holidays.find_all {|_item| _item.user_id == item.id}
      )

      ass = item.association(:year_journals)
      ass.loaded!
      ass.target.concat(
        year_journals.find_all {|_item| _item.user_id == item.id}
      )

      ass = item.association(:journals)
      ass.loaded!
      ass.target.concat(journals.find_all {|_item| _item.user_id == item.id})

      item.calculate_journal(rule,task.date)
      leader_user.ref_cmd[0] += item.ref_cmd.length
    end

    users.sort!{|a,b| b.ref_cmd.length <=> a.ref_cmd.length }
  end

end
