class EmSerCate < ActiveRecord::Base
  has_many :em_services, dependent: :delete_all
end
