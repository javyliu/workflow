class Usermailer < ApplicationMailer

  #for test email
  def welcome_email(user_id)
    @user = User.find(user_id)
    full_mailname = %("#{@user.user_name}" <#{@user.email}>)
    mail(to: full_mailname,subject: 'welcome to use mailers',body: "no body",content_type: "text/html")
  end

  #每日需发送的考勤邮件
  def daily_kaoqing(leader_user_id)
    @leader_user = User.find(leader_user_id)
    @rule = AttendRule.find(@leader_user.leader_data[1])
    @users = User.where(uid: @leader_user.leader_data.try(:last)).includes(:dept,:yesterday_checkin,:last_year_info,:yes_holidays).decorate
    @leader_user = @leader_user.decorate

    #Sidekiq.redis do |_redis|
    #  _redis.hmset(leader_user_id,atten_rule: atten_rule,uids: uids)
    #end
    @date = Date.today
    full_mailname = %("刘泉" <qmliu@pipgame.com>)
    mail(to: full_mailname,subject: "考勤确认单{F001:CFM:#{leader_user_id}:#{@date}}")#,body: "no body",content_type: "text/html")
  end
end
