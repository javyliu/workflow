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
    yesterday = Date.yesterday

    leaders = User.cached_leaders

    is_workday = SpecDay.workday?(yesterday)

    #每日发送前一天部门的考勤邮件，如果昨天是工作日 ，则发送每个部门的考勤邮件，如果是非工作日 ，则只发送有考勤异常部门的邮件
    unless is_workday
      y_checkin_uids = Checkinout.where(rec_date: yesterday.to_s).pluck(:user_id)
      y_checkin_uids.compact.each do |uid|
        leaders.each do |item|
          item.push(uid) if item[2].include?(uid)
        end
      end
      leaders = leaders.collect { |leader_user_id,rule_id,_,*checkin_uids| [leader_user_id,rule_id,checkin_uids] }
    end

    #构建邮件并发出去
    leaders.each do |leader_item|
      #发送邮件
      if uids.length > 0
        Usermailer.daily_kaoqing(leader_user_id).deliver_later
        #如果是非工作日，则会在任务池中增加一个任务，否则在生成邮件时如部门有考勤异常则发起催缴任务
        User.create_task(*leader_item,start: !is_workday)
        puts "sending mail #{leader_user_id},#{date} "
      end
    end

    puts "i am preforming"
  end

end
