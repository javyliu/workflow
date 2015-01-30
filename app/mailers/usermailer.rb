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
    @date = opts[:date] || Date.yesterday
    @count = opts[:count]
    preview = opts[:preview]


    #date = Date.today - 3.days

    @leader_user = User.find(leader_user_id)
    @rule = AttendRule.find(@leader_user.leader_data[1])


    @leader_user = @leader_user.decorate
    @leader_user.report_titles = ReportTitle.where(id: @rule.title_ids).order("ord,id")
    @leader_user.uids = uids

    @task = Task.new("F001",leader_user_id,date: @date)
    #预览时不生成任务,如果考勤计算完毕且非异常考勤，则删除任务
    if !preview && @leader_user.ref_cmd[0] == 0
      @task.remove
    end

    mail_subject = @count ? "催缴考勤确认单{#{@task.task_name}}第#{@count}次" : "考勤确认单{#{@task.task_name}}"


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
    #TODO: need change to leader_user.email_name
    full_mailname = %("刘泉" <javy_liu@163.com>)
    mail(to: full_mailname,subject: "考勤确认错误{#{date}}")#,body: "no body",content_type: "text/html")
  end
end
