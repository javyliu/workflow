class Usermailer < ApplicationMailer
  #for test email
  #default bcc: 'qmliu@pipgame.com'
  FullMailname = %("javy" <javy_liu@163.com>)
  HandleErrorUser = %("qmliu" <qmliu@pipgame.com>)

  #发送邮件给错误处理人员
  def expired_error(task_name)
    @task = Task.init_from_subject(task_name)
    @user = User.find(@task.leader_user_id)
    @msg = "#{@user.user_name}的#{@task.type_name} #{@task.to_s} 过期未确认"

    mail(to: HandleErrorUser,subject: "#{@task.type_name}过期未确认")#,body: "no body",content_type: "text/html")
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
    rule = AttendRule.find(@leader_user.leader_data[1])


    @leader_user = @leader_user.decorate
    @leader_user.report_titles = ReportTitle.where(id: rule.title_ids).order("ord,id")
    @leader_user.uids = uids

    @task = Task.new("F001",leader_user_id,date: @date)
    @users = Task.eager_load_from_task(@task,leader_user: @leader_user,rule: rule)
    #预览时不生成任务,如果考勤计算完毕且非异常考勤，则删除任务
    if !preview && @leader_user.ref_cmd[0] == 0
      @task.remove
    end

    mail_subject = @count ? "催缴考勤确认单{#{@task.task_name}}第#{@count}次" : "考勤确认单{#{@task.task_name}}"


    #TODO: need change to leader_user.email
    full_mailname = FullMailname
    mail(to: full_mailname,subject: mail_subject )#,body: "no body",content_type: "text/html")
  end

  #日常考勤确认邮件
  def daily_approved(leader_user_id,changed_user_names,date)
    @leader_user = User.find(leader_user_id)
    @date = date
    @changed_user_names = changed_user_names
    #TODO: need change to leader_user.email
    full_mailname = FullMailname
    mail(to: full_mailname,subject: "考勤确认完成{#{date}}")#,body: "no body",content_type: "text/html")
  end

  def error_approved(leader_user_id,msg,date)
    @leader_user = User.find(leader_user_id)
    @date = date
    @error_msg = msg
    #TODO: need change to leader_user.email_name
    full_mailname = FullMailname
    mail(to: full_mailname,subject: "考勤确认错误{#{date}}")#,body: "no body",content_type: "text/html")
  end
end
