class Checkinout < ActiveRecord::Base
  belongs_to :user
  #得到昨日签到人员，仅用于是节假日 的情况
  #scope :yesterday_checkins, -> { select("").joins(:checkinouts).where(rec_date: Date.yesterday.to_s)}
  #scope :dry_clean_only, -> { joins(:washing_instructions).where('washing_instructions.dry_clean_only = ?', true) }
  include JavyTool::Csv
  include JavyTool::ConstructQuery

end
