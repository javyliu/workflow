class SpecDay < ActiveRecord::Base
  after_save :delete_redis_cache


  #是否工作日
  def self.workday?(date: Date.today)
    (spec_day = cached_spec_days.assoc(date.to_s)) && spec_day[1] == true
  end

  def self.cached_spec_days
    Sidekiq.redis do |_redis|
      holiday = _redis.get(:spec_days)
      holiday ||= _redis.set(:spec_days,self.all.collect{|item|[item.sdate.to_s,item.is_workday,item.comment]}) && _redis.get(:spec_days)
      JSON.parse(holiday)
    end
  end

  private

  def delete_redis_cache
    Sidekiq.redis do |_redis|
      _redis.del(:spec_days)
    end
  end

end
