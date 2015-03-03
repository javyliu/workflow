class DailyMailJob < ActiveJob::Base
  queue_as :default

#  before_enqueue do |job|
#    puts(job.class)
#    puts(job.inspect)
#    return false
#  end


  #TODO: need add workday judge,if not workday don't send email
  #need use before_action
  def perform(*args)
    #leader with employees in user_ids
    #has attributes uid,user_ids,atten_rule

    opts = args.extract_options!

    yesterday = Date.yesterday
    leaders = User.leaders_by_date(yesterday)
    #用于测试
    if opts[:leader_user_id]
      leaders = [leaders.detect { |e| e[0] == opts[:leader_user_id] }]
    end

    #puts leaders.inspect
    #构建邮件并发出去
    leaders.each do |leader_user_id,rule_id,checkin_uids|
      #发送邮件
      #TODO:是否还要保留checkin_uids?
      if checkin_uids.length > 0
        Task.create("F001",leader_user_id,leader_user_id: leader_user_id,checkin_uids: checkin_uids.uniq.to_json,date: yesterday.to_s)
        Usermailer.daily_kaoqing(leader_user_id,uids: checkin_uids.uniq,date: yesterday.to_s).deliver_later
        puts "sending daily mail #{leader_user_id} "
      end
    end

    puts "i am preforming"
  end

end
