# == Schema Information
#
# Table name: checkinouts
#
#  id         :integer          not null, primary key
#  user_id    :string(20)
#  rec_date   :date
#  checkin    :datetime
#  checkout   :datetime
#  ref_time   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Checkinout < ActiveRecord::Base
  belongs_to :user
  #得到昨日签到人员，仅用于是节假日 的情况
  #scope :yesterday_checkins, -> { select("").joins(:checkinouts).where(rec_date: Date.yesterday.to_s)}
  #scope :dry_clean_only, -> { joins(:washing_instructions).where('washing_instructions.dry_clean_only = ?', true) }
  include JavyTool::Csv
  #include JavyTool::ConstructQuery

end
