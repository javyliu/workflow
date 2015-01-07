class User < ActiveRecord::Base
  self.primary_key = 'uid'
  belongs_to :department,foreign_key: :dept_code,touch: true
end
