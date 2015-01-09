class AttendRule < ActiveRecord::Base
  serialize :title_ids, Array
  has_many :departments
end
