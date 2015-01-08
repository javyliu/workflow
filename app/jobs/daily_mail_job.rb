class DailyMailJob < ActiveJob::Base
  queue_as :default

  before_enqueue do |job|
    puts(job.class)
    puts(job.inspect)
    #$statsd.increment "enqueue-video-job.try"
  end


  #TODO: need add workday judge,if not workday don't send email
  #need use before_action
  def perform(*args)
    #leader with employees in user_ids
    #has attributes uid,user_ids,atten_rule

    #构建邮件并发出去
    User.cached_leaders.each do |leader_user_id,atten_rule,uids|
      #发送邮件
      #Usermailer.daily_kaoqing(leader_user_id,atten_rule,uids,date: Date.today).deliver_now
      puts "sending mail #{leader_user_id},#{atten_rule},#{uids} "

      #Sidekiq.redis do |_redis|
      #  _redis.hmset(leader_user_id,atten_rule: atten_rule,uids: uids)
      #end
    end

    puts "i am preforming"
  end
end
