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
  #has_many :approves,dependent: :delete_all
  has_many :approves, as: :approveable, dependent: :delete_all

  validates :user_id,:comment,:start_date,:end_date,:title,:total_time, presence: true
  #validates_uniqueness_of :ck_type, conditions: -> {|args| where("? between start_date and end_date", Time.now.to_date )}

  has_many :children, class_name: 'Episode',foreign_key: :parent_id,dependent: :delete_all

  accepts_nested_attributes_for :children,:allow_destroy => true, :reject_if => :all_blank

  #belongs_to :parent,class_name: 'Episode',foreign_key: :parent_id
  before_validation :init_attr


  validate do
    #用户在相同日期内是否存在同类假期
    is_exist_con = Episode.where(["user_id = :user_id and holiday_id = :holiday_id and  (date(start_date) <= :start_date  and end_date >= :start_date or :start_date <= date(start_date) and :end_date >= date(start_date) )",user_id: self.user_id,holiday_id: self.holiday_id,start_date: self.start_date.to_date,end_date: self.end_date.to_date])
    is_exist_con = is_exist_con.where("id != ?",self.id) unless self.new_record?
    errors.add(:base, '已经存在同类申请了，请删除后再次申请！') if is_exist_con.exists?

    #一个薪资周期（上月26日到本月25日）内只允许申请3次迟到早退特批
    #2016-03-29 取消次数限制
    #if holiday_id == 19
    #  s_date,e_date = Journal.count_time_range(date: self.start_date.to_date)
    #  is_exist_con = Episode.where("user_id = :user_id and holiday_id = 19 and start_date > :start_date and start_date < :end_date", user_id: user_id, start_date: s_date, end_date: e_date.next_day  )
    #  is_exist_con = is_exist_con.where("id != ?",self.id) unless self.new_record?
    #  errors.add(:base, '迟到早退特批假每月只允许申请三次，如有疑问，请与人事联系！') if is_exist_con.count(1) >= 3
    #end


  end

  #get the parent episode
  #if no parent return self
  def parent
    self.parent_id == 0 ? self : Episode.find_by_id(self.parent_id)
  end


  State = [["未审批",0],["通过",1],["未通过",2],["审核中",3]]
  Title = [["员工",501],["主管",402],["经理",302],["总监",202],["副总",101]]

  include JavyTool::Csv
  #只有父假单会发送状态更改通知邮件
  after_save :send_email,if: -> {self.state_changed? && self.parent_id == 0 && self.state != 0}
  after_save :update_children, on: :create, if: -> {self.parent_id == 0}

  def sum_total_day
    @sum_total_day ||= self.children.to_a.push(self).inject(0){|sum,item| sum += calcucate_day_total(item)}
  end

  private

  #给提交者发送邮件
  def send_email
    Usermailer.episode_approved(self.id).deliver_later
  end

  def init_attr
    self.ck_type ||= Journal::CheckType.detect{|item|item[6] == self.holiday_id}.try(:second)
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

  #更新子假单
  def update_children
    self.children.update_all(state: state)
  end
end
