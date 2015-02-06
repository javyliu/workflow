class ApplicationMailer < ActionMailer::Base
  #TODO: need to update x.pipgame.com when production
  default from: '"考勤邮件" <y@pipgame.com>'
  layout 'mailer'
end
