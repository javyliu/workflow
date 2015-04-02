class SysKaoqingDataJob < ActiveJob::Base
  queue_as :default

  #让该任务每天凌晨5点执行
  #用于同步打卡记录
  def perform(*args)
    #Sidekiq.redis do |conn|
    #  conn.incrby('foo', count)
    #end
    #binding.pry
    opts = args.extract_options!
    Rails.logger.info("JOB #{Time.now.to_s(:db)} #{opts.inspect}")
    CharesDatabase::Checkinout.sys_data(opts[:from],opts[:to])
  end
end
