# == Schema Information
#
# Table name: approves
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  user_name  :string(20)
#  state      :integer          default("0")
#  des        :string(255)
#  episode_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Approve < ActiveRecord::Base
  #belongs_to :episode
  belongs_to :user
  belongs_to :approveable, polymorphic: true
end
