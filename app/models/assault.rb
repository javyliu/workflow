class Assault < ActiveRecord::Base
  belongs_to :user
  has_one :approve, as: :approveable, dependent: :delete
  validates :user_id,:description,:cate,:start_date, presence: true

  serialize :employees, Array

  #使用Episode::State
  after_save :update_related_model,if: -> {self.state_changed? && self.state != 0}

  Cates = ["995","996"]

  def users
    User.where(uid: employees)
  end

  def dis_name
    @dis_name ||= (style == 0 ? "突击" : "取消突击") + "#{cate}"
  end

  private

  def update_related_model
    #更新用户状态
    if state == 1  #审核通过时，更新用户的 assault_start_date 及 assault_end_date
      if style == 0 #申请进入突击状态
        User.where(uid: employees).update_all(assault_start_date: start_date, assault_end_date: end_date)
      else #申请退出突击状态
        #User.where(uid: employees).update_all(assault_start_date: nil, assault_end_date: nil)
        CancelUserAssaultDateJob.set(wait_until: self.start_date.beginning_of_day).perform_later(self)
      end
    end

    #发送邮件
    Usermailer.assault_approved(self.id).deliver_later
  end

end
