class SysKaoqingDataJob < ActiveJob::Base
  queue_as :default

  #让该任务每天凌晨5点执行
  def perform(*args)
    #Sidekiq.redis do |conn|
    #  conn.incrby('foo', count)
    #end
    puts args.inspect
    CharesDatabase::Tblcheckinout.sys_data(Date.yesterday,Date.today)
    puts "end"

  end
end
