class AttendRule < ActiveRecord::Base
  serialize :title_ids, Array
  has_many :departments

  SpecRuleNames = %w{ab_point4_qiLe ab_point}


end
