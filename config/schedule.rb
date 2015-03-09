# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "~/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
#every 4.days do
#  runner "AnotherModel.prune_old_records"
#end

#每天早上5点同步checkinout数据库
job_type :job, "cd :path && :environment_variable=:environment bin/sidekiq_pusher :task :output"
every 1.day,at: '5am' do
  job "SysKaoqingDataJob"
end

#每天早上8.00发出每日考勤邮件
every 1.day,at: '8:30' do
  job "DailyMailJob"
end

every '*/2 * * * *' do
  job "ReceiveEmailJob"
end

every '* 10,14 * * *' do
  job "PromptDailyMailJob"
end
#every 1.day,at: '6am' do
#  runner "AnotherModel.prune_old_records"
#end
# Learn more: http://github.com/javan/whenever
