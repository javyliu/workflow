class ApplicationMailer < ActionMailer::Base
  #TODO: need to update x.pipgame.com when production
  default from: '"考勤邮件" <qmliu@pipgame.com>'
  layout 'mailer'
end
