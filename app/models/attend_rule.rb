# == Schema Information
#
# Table name: attend_rules
#
#  id          :integer          not null, primary key
#  name        :string(30)
#  description :string(40)
#  title_ids   :string(255)
#  time_range  :string(40)       default("0")
#  min_unit    :integer          default("30")
#  created_at  :datetime         default("2015-01-14 15:38:29"), not null
#  updated_at  :datetime         default("2015-01-14 15:38:29"), not null
#

class AttendRule < ActiveRecord::Base
  serialize :title_ids, Array
  has_many :departments

  SpecRuleNames = %w{ab_point4_qiLe ab_point}

  before_save :adjust_title_ids


  def self.list
    @list ||= self.pluck(:description,:id,:name)
  end


  private

  def adjust_title_ids
    self.class.instance_variable_set(:@list, nil)
    self[:title_ids] = self.title_ids.keep_if{|item|item.present?}.map{|item| item.to_i}
  end


end
