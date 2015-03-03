class Holiday < ActiveRecord::Base
  has_many :episodes

  #假期计算单位，
  #哺乳期晚到1小时，哺乳期早走1小时,漏打卡 为次
  #假休为小时
  #其它为天
  def self.unit(holiday_id)
    case holiday_id
    when 2,3,7
      "次"
    when 5
      "小时"
    else
      "天"
    end

  end
  def unit
    self.class.unit(self.id)
  end
end
