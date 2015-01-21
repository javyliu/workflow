class Usermailer < ApplicationMailer
  #for test email
  def welcome_email(user_id)
    @user = User.find(user_id)
    full_mailname = %("#{@user.user_name}" <#{@user.email}>)
    mail(to: full_mailname,subject: 'welcome to use mailers',body: "no body",content_type: "text/html")
  end

  #每日需发送的考勤邮件
  #def daily_kaoqing(leader_user_id,uids = nil,date = nil,preview = nil)
  def daily_kaoqing(*args)
    #leader_user_id,uids = nil,date = nil,preview = nil
    opts = args.extract_options!

    leader_user_id = args.first

    uids = opts[:uids]
    date = opts[:date]
    @count = opts[:count]
    preview = opts[:preview]

    logger.info("-------------now is #{leader_user_id} #{uids}")
    #must set the date if the date is not yesterday
    #can't do the because of the thread safe
    #User.query_date = date

    #date = Date.today - 3.days

    @leader_user = User.find(leader_user_id)
    @rule = AttendRule.find(@leader_user.leader_data[1])
    uids = uids ||  @leader_user.leader_data.try(:last)
    date ||= Date.yesterday
    #@users = User.where(uid: @leader_user.leader_data.try(:last)).includes(:dept,:yesterday_checkin,:last_year_info,:yes_holidays,:year_journals).decorate
    @users = User.where(uid: uids).includes(:dept,:last_year_info,:year_journals).decorate

    date_checkins = Checkinout.where(user_id: uids,rec_date: date.to_s).to_a

    yes_holidays = Holiday.select("holidays.*,episodes.user_id user_id").joins(:episodes).where(["user_id in (:users) and start_date <= :yesd and end_date >= :yesd ",yesd: date.to_s,users: uids]).to_a


    @leader_user = @leader_user.decorate
    @leader_user.ref_cmd[0] = 0
    @users.each do |item|
      #manually preload yesterday_checkin and yes_holiday
      ass = item.association(:yesterday_checkin)
      ass.loaded!
      ass.target = date_checkins.detect{|_item| _item.user_id == item.id }

      ass = item.association(:yes_holidays)
      ass.loaded!
      ass.target.concat(
        yes_holidays.find_all {|_item| _item.user_id == item.id}
      )

      item.calculate_journal(@rule)
      @leader_user.ref_cmd[0] += item.ref_cmd.length
    end

    _task = Task.new("F001",leader_user_id,date: date)
    #预览时不生成任务
    if !preview && @leader_user.ref_cmd[0] == 0
      _task.remove
    end

    mail_subject = @count ? "催缴考勤确认单{#{_task.task_name}}第#{@count}次" : "考勤确认单{#{_task.task_name}}"

    @users.sort!{|a,b| b.ref_cmd.length <=> a.ref_cmd.length }

    @date = date
    #TODO: need change to leader_user.email
    full_mailname = %("刘泉" <javy_liu@163.com>)
    mail(to: full_mailname,subject: mail_subject )#,body: "no body",content_type: "text/html")
  end

  #日常考勤确认邮件
  def daily_approved(leader_user_id,changed_user_names,date)
    @leader_user = User.find(leader_user_id)
    @date = date
    @changed_user_names = changed_user_names
    #TODO: need change to leader_user.email
    full_mailname = %("刘泉" <javy_liu@163.com>)
    mail(to: full_mailname,subject: "考勤确认完成{#{date}}")#,body: "no body",content_type: "text/html")
  end

  def error_approved(leader_user_id,msg,date)
    @leader_user = User.find(leader_user_id)
    @date = date
    @error_msg = msg
    #TODO: need change to leader_user.email
    full_mailname = %("刘泉" <javy_liu@163.com>)
    mail(to: full_mailname,subject: "考勤确认错误{#{date}}")#,body: "no body",content_type: "text/html")
  end
end
