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
    #昨天如果是工作日 ，则发送考勤邮件，如果是非工作日 ，则只发送有加班的部门的邮件
    unless SpecDay.workday?(yesterday)
      y_checkin_uids = Checkinout.where(rec_date: yesterday.to_s).pluck(:user_id)
      y_checkin_uids.compact.each do |uid|
        leaders.each do |item|
          item.push(uid) if item[2].include?(uid)
        end
      end
      leaders = leaders.collect { |mgr_code,rule,_,*checkin_uids| [mgr_code,rule,checkin_uids] }
    end

    #构建邮件并发出去
    leaders.each do |leader_user_id,atten_rule,uids|
      #发送邮件
      if uids.length > 0
        Usermailer.daily_kaoqing(leader_user_id,atten_rule,uids,date: Date.today).deliver_now
        puts "sending mail #{leader_user_id},#{atten_rule},#{uids} "
      end
    end

    puts "i am preforming"
  end
end
