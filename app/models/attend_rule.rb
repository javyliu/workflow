class AttendRule < ActiveRecord::Base
  serialize :title_ids, Array
end
