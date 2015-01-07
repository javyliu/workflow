class Department < ActiveRecord::Base
  has_many :users,foreign_key: :dept_code
end
