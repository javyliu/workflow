class AttendRule < ActiveRecord::Base
  serialize :title_ids, Array
  has_many :departments

  SpecRuleNames = %w{ab_point4_qiLe ab_point}

  before_save :adjust_title_ids


  private

  def adjust_title_ids
    self[:title_ids] = self.title_ids.keep_if{|item|item.present?}.map{|item| item.to_i}
  end


end
