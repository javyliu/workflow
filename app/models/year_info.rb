# == Schema Information
#
# Table name: year_infos
#
#  id           :integer          not null, primary key
#  year         :integer
#  user_id      :string(20)
#  year_holiday :integer          default("0")
#  sick_leave   :integer          default("0")
#  affair_leave :integer          default("0")
#  switch_leave :integer          default("0")
#  ab_point     :integer          default("0")
#  created_at   :datetime         default("2015-01-09 22:02:50"), not null
#  updated_at   :datetime         default("2015-01-09 22:02:50"), not null
#

class YearInfo < ActiveRecord::Base
  belongs_to :user

  include JavyTool::Csv

end
