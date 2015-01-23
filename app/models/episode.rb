class Episode < ActiveRecord::Base
  belongs_to :holiday
  belongs_to :user
end
