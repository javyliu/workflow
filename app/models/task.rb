class Task
  attr_accessor :type
  attr_accessor :date
  attr_accessor :leader_user_id
  attr_accessor :action_name

  SubjectRex = /\{(\w+):(\w+):([-\d]+)\}/
  Expired = "expired"
  Completed = "completed"
  Pending = "pending"

  #不同类型的确认单对应的邮件方法
  CfmType= [
    ["考勤确认单","daily_kaoqing","F001"],
    ["请假确认单","approve_holiday","F002"]
  ]

  def initialize(type,leader_user_id,date: nil)
    self.type = type
    self.leader_user_id = leader_user_id
    self.action_name = CfmType.rassoc(type).try(:second)
    self.date = date || Date.yesterday.to_s
  end

  def self.init_from_subject(subject)
    return false unless subject.is_utf8?
    type,leader_user_id,date = Task::SubjectRex.match(subject).try(:captures)
    if type.blank? || date.blank? || leader_user_id.blank?
      return false
    end
    Task.new(type,leader_user_id,date: date)
  end

  def task_name
    @task_name ||=  "#{type}:#{leader_user_id}:#{date.to_s}"
  end

  def update(key,value)
    Sidekiq.redis do |conn|
      conn.hset(self.task_name,key.to_s,value)
    end
  end

  def increment!
    Sidekiq.redis do |conn|
      conn.hincrby(self.task_name,"count",1)
    end
  end

  def self.pending_tasks
    Sidekiq.redis do |conn|
      conn.smembers("task:pendings")
    end
  end

  def attr_value(key)
    Sidekiq.redis do |conn|
      conn.hget(self.task_name,key.to_s)
    end
  end

  def count
    self.attr_value("count").to_i
  end

  def content
    @content ||= Sidekiq.redis do |conn|
      conn.hgetall(self.task_name)
    end
  end

  def exists?
    Sidekiq.redis do |conn|
      conn.sismember("task:pendings",self.task_name)
    end
  end


  def self.create(*args)#type,leader_user_id,rule_id,checkin_uids,action)
    opts = args.extract_options!
    type,leader_user_id = args
    raise "type is nil" if type.nil? || leader_user_id.nil?
    _task = self.new(type,leader_user_id,date: opts.delete(:date))
    Sidekiq.redis do |conn|
      conn.hmset(_task.task_name,"state",Task::Pending,"count",0,"date",_task.date,*opts.to_a.flatten(1))
      conn.sadd("task:pendings",_task.task_name)
    end
    _task
  end

  def self.remove(type,leader_user_id,date: nil)
    _task = self.new(type,leader_user_id,date: date)
    _task.remove
  end

  def remove
    Sidekiq.redis do |conn|
      conn.srem("task:pendings",self.task_name)
    end
  end


end
