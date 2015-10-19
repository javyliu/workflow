# == Schema Information
#
# Table name: episodes
#
#  id         :integer          not null, primary key
#  user_id    :string(20)
#  title      :string(20)
#  total_time :string(20)
#  holiday_id :integer
#  start_date :datetime
#  end_date   :datetime
#  comment    :string(500)
#  state      :integer          default("0")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ck_type    :integer
#

class Episode < ActiveRecord::Base
  belongs_to :holiday
  belongs_to :user
  has_many :approves,dependent: :delete_all

  validates :user_id, presence: true
  validates :comment, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :title, presence: true
  validates :total_time, presence: true

  has_many :children, class_name: 'Episode',foreign_key: :parent_id,dependent: :delete_all

  accepts_nested_attributes_for :children,:allow_destroy => true, :reject_if => :all_blank

  #belongs_to :parent,class_name: 'Episode',foreign_key: :parent_id
  before_save :init_attr

  #get the parent episode
  #if no parent return self
  #def parent
  #  self.parent_id == 0 ? self : Episode.find_by_id(self.parent_id)
  #end


  State = [["未审批",0],["通过",1],["未通过",2],["审核中",3]]
  Title = [["员工",501],["主管",402],["经理",302],["总监",202],["副总",101]]

  include JavyTool::Csv
  #只有父假单会发送状态更改通知邮件
  after_save :send_email,if: -> {self.state_changed? && self.parent_id == 0 && self.state != 0}

  def sum_total_day
    @sum_total_day ||= self.children.to_a.push(self).inject(0){|sum,item| sum += calcucate_day_total(item)}
  end

  private

  #给提交者发送邮件
  def send_email
    Usermailer.episode_approved(self.id).deliver_later
  end

  def init_attr
    self.ck_type = Journal::CheckType.detect{|item|item[6] == self.holiday_id}.try(:second)
  end

  def calcucate_day_total(episode)
      case Holiday.unit(episode.holiday_id)
      when "天"
        episode.total_time.to_f
      when "小时"
        episode.total_time.to_i/8.0
      else
        0
      end
  end
end
