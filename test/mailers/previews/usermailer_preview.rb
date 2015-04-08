# Preview all emails at http://localhost:3000/rails/mailers/usermailer
class UsermailerPreview < ActionMailer::Preview

  def daily_kaoqing
    #Rails.logger.info(request)
    Usermailer.daily_kaoqing("1416",date: '2015-04-03',preview: true)
  end

  def daily_approved
    #Rails.logger.info(request)
    Usermailer.daily_approved("1461",%w(a b c d e f g),Date.yesterday.to_s())
  end

  def episode_approve
    Usermailer.episode_approve('F002:1416:2015-03-24:23')
  end

  def episode_approved
    Usermailer.episode_approved(21)
  end

  def error_approved
    #Rails.logger.info(request)
    Usermailer.error_approved("1461","你已经确认过了",Date.yesterday.to_s())
  end
end
