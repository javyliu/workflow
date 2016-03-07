class CancelUserAssaultDateJob < ActiveJob::Base
  queue_as :default

  def perform(assault)
    if assault.style == 1 #取消突击状态
      User.where(uid: assault.employees).update_all(assault_start_date: nil, assault_end_date: nil)
      Rails.logger.info("JOB #{Time.now.to_s(:db)} 取消突击状态")
    end
  end
end
