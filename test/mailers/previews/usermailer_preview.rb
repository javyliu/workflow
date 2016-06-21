# Preview all emails at http://localhost:3000/rails/mailers/usermailer
class UsermailerPreview < ActionMailer::Preview

  def unify_update
    #Rails.logger.info(request)
    Usermailer.unify_update("1416","密码重置通知", "您的公司账号密码于#{Time.now.to_s(:F)}被重置为 12123")
  end

  def info_msg
    #Rails.logger.info(request)
    Usermailer.info_msg("1416","申请删除通知", "您的哺乳期晚到1小时  次申请已被 刘泉美 删除。")
  end

  def daily_kaoqing
    #Rails.logger.info(request)
    Usermailer.daily_kaoqing("1416",date: '2016-06-19',preview: true)
  end

  def daily_approved
    #Rails.logger.info(request)
    Usermailer.daily_approved("1461",%w(a b c d e f g),Date.yesterday.to_s())
  end

  def episode_approve
    Usermailer.episode_approve('F002:1416:2015-10-19:35')
  end

  def assault_approve
    Usermailer.assault_approve('F003:1004:2016-03-04:3')
  end

  def assault_approved
    Usermailer.assault_approved(3)
  end

  def episode_approved
    Usermailer.episode_approved(21)
  end

  def error_approved
    #Rails.logger.info(request)
    Usermailer.error_approved("1461","你已经确认过了",Date.yesterday.to_s())
  end
end
