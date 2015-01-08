class Usermailer < ApplicationMailer

  #for test email
  def welcome_email(user_id)
    @user = User.find(user_id)
    full_mailname = %("#{@user.user_name}" <#{@user.email}>)
    mail(to: full_mailname,subject: 'welcome to use mailers',body: "no body",content_type: "text/html")
  end

  #每日需发送的考勤邮件
  def daily_kaoqing(leader_user_id,atten_rule,uids,date: Date.today)
    @leader_user = User.find(leader_user_id)
    @rules = @leader_user.department.atten_rule
    @users = User.where(uid: uids).includes(:department,:yesterday_checkins)
    @users = @users.decorate

    #Sidekiq.redis do |_redis|
    #  _redis.hmset(leader_user_id,atten_rule: atten_rule,uids: uids)
    #end
    @date = date || Date.today
    full_mailname = %("刘泉" <qmliu@pipgame.com>)
    mail(to: full_mailname,subject: "考勤确认单{F001:CFM:#{leader_user_id}:#{date}}")#,body: "no body",content_type: "text/html")
  end
end
