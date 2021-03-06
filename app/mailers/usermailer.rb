class Usermailer < ApplicationMailer
  #for test email
  #default bcc: 'qmliu@pipgame.com'
  FullMailname = %("javy" <javy_liu@163.com>)
  HandleErrorUser = %("kaoqin" <kaoqin@pipgame.com>)

  #发送邮件给错误处理人员
  def expired_error(task_name)
    @task = Task.init_from_subject(task_name)
    @user = User.find(@task.leader_user_id)
    @msg = "#{@user.user_name}的#{@task.type_name} #{@task.to_s} 过期未确认"

    mail(to: HandleErrorUser,subject: "#{@task.type_name}过期未确认")#,body: "no body",content_type: "text/html")
  end

  def info_msg(to_user_id,subject,content)
    @user = User.find(to_user_id)
    @content = content

    mail(to: @user.email_name ,subject: subject) #,body: "no body",content_type: "text/html")
  end

  #发送假期确认邮件
  def episode_approve(task_name)
    @task = Task.init_from_subject(task_name)
    @leader_user = User.find(@task.leader_user_id)
    @episode = Episode.find(@task.mid)
    #rule = AttendRule.find(@leader_user.leader_data[1])
    #full_mailname = rule.name.start_with?("ab") ? FullMailname : %("#{@leader_user.user_name}" <#{@leader_user.email}>)
    full_mailname = @leader_user.email_name
    mail(to: full_mailname,subject: @task.type_name)#,body: "no body",content_type: "text/html")
  end

  #给员工发送假期确认邮件
  def episode_approved(episode_id)
    @episode = Episode.find(episode_id)
    #rule = AttendRule.find(@leader_user.leader_data[1])
    #full_mailname = rule.name.start_with?("ab") ? FullMailname : %("#{@leader_user.user_name}" <#{@leader_user.email}>)
    @user = @episode.user
    mail(to: @user.email_name,subject: "#{@episode.holiday.name}申请确认单")#,body: "no body",content_type: "text/html")
  end

  #发送突击申请确认邮件
  def assault_approve(task_name)
    @task = Task.init_from_subject(task_name)
    @leader_user = User.find(@task.leader_user_id)
    @assault = Assault.find(@task.mid)
    #rule = AttendRule.find(@leader_user.leader_data[1])
    #full_mailname = rule.name.start_with?("ab") ? FullMailname : %("#{@leader_user.user_name}" <#{@leader_user.email}>)
    full_mailname = @leader_user.email_name
    mail(to: full_mailname,subject: "#{@assault.dis_name}申请单")#,body: "no body",content_type: "text/html")
  end

  #给申请人发送突击申请确认邮件
  def assault_approved(assault_id)
    @assault = Assault.find(assault_id)
    @approve = @assault.approve
    @user = @assault.user
    mail(to: @user.email_name,subject: "#{@assault.dis_name}申请确认单")#,body: "no body",content_type: "text/html")
  end

  #每日需发送的考勤邮件
  #def daily_kaoqing(leader_user_id,uids = nil,date = nil,preview = nil)
  def daily_kaoqing(*args)
    #leader_user_id,uids = nil,date = nil,preview = nil
    opts = args.extract_options!

    leader_user_id = args.first

    uids = opts[:uids]
    @date = opts[:date] || Date.yesterday.to_s
    @wday = I18n.t("date.day_names")[Date.parse(@date).wday]
    @count = opts[:count]
    preview = opts[:preview]


    #date = Date.today - 3.days
    if leader_user_id.blank?
        Rails.logger.info  "Error: leader_user_id is blank"
        return false
    end


    @leader_user = User.find(leader_user_id)
    rule = AttendRule.find(@leader_user.leader_data["attend_rule_id"])
    @rule = rule


    @leader_user = @leader_user.decorate
    #id= 40的列为“其它“
    @leader_user.report_titles = ReportTitle.where(id: (rule.title_ids + [40])).order("ord,id").find_all{|item| !item.name.in?(Journal.mail_dec_identities)}
    @leader_user.uids = uids

    @task = Task.new("F001",leader_user_id,date: @date)
    @users = Task.eager_load_from_task(@task,leader_user: @leader_user,rule: rule)
    #全勤，删除催缴及提醒任务
    #预览时不生成任务,如果考勤计算完毕且非异常考勤，则删除任务
    if !preview && @leader_user.ref_cmd[0] == 0
      @task.remove(all: true)
    end

    mail_subject = @count ? "催缴考勤确认单{#{@task.task_name}}第#{@count}次" : "考勤确认单{#{@task.task_name}}"


    #TODO: need change to leader_user.email
    #full_mailname = rule.name.start_with?("ab") ? FullMailname : %("#{@leader_user.user_name}" <#{@leader_user.email}>)
    full_mailname = @leader_user.email_name
    mail(to: full_mailname,subject: mail_subject )#,body: "no body",content_type: "text/html")
  end

  #日常考勤确认邮件
  def daily_approved(leader_user_id,changed_user_names,date)
    @leader_user = User.find(leader_user_id)
    @date = date
    @changed_user_names = changed_user_names
    #TODO: need change to leader_user.email
    #rule = AttendRule.find(@leader_user.leader_data[1])
    #full_mailname = rule.name.start_with?("ab") ? FullMailname : %("#{@leader_user.user_name}" <#{@leader_user.email}>)
    full_mailname = @leader_user.email_name
    mail(to: full_mailname,subject: "考勤确认完成{#{date}}")#,body: "no body",content_type: "text/html")
  end

  def error_approved(leader_user_id,msg,date)
    @leader_user = User.find(leader_user_id)
    @date = date
    @error_msg = msg
    #TODO: need change to leader_user.email_name
    #rule = AttendRule.find(@leader_user.leader_data[1])
    #full_mailname = rule.name.start_with?("ab") ? FullMailname : %("#{@leader_user.user_name}" <#{@leader_user.email}>)
    full_mailname = @leader_user.email_name
    mail(to: full_mailname,subject: "考勤确认错误{#{date}}")#,body: "no body",content_type: "text/html")
  end

  #更改密码邮件
  def unify_update(user_id,subject,content)
    @user = User.find(user_id)
    full_mailname = @user.email_name
    @content = content
    mail(to: full_mailname,subject: subject, from: '"密码管理员" <mis@pipgame.com>')#,body: "no body",content_type: "text/html")

  end
end
