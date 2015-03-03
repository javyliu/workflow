class Episode < ActiveRecord::Base
  belongs_to :holiday
  belongs_to :user
  has_many :approves

  validates :user_id, presence: true
  validates :comment, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :title, presence: true
  validates :total_time, presence: true

  State = [["未审批",0],["通过",1],["未通过",2],["审核中",3]]
  Title = [["员工",501],["主管",402],["经理",302],["总监",202],["副总",101]]
end
