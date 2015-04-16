class Holiday < ActiveRecord::Base
  has_many :episodes

  #假期计算单位，
  #哺乳期晚到1小时，哺乳期早走1小时,漏打卡 为次
  #假休为小时
  #其它为天
  #1病假
  #2哺乳期晚到1小时
  #3哺乳期早走1小时
  #4产假/产检假
  #5倒休
  #6事假
  #7漏打卡
  #8带薪事假
  #9带薪病假
  #10年假
  #11陪产假
  #12婚假
  #13丧假
  #14外出
  #15出差
  #16特批
  #17加班
  def self.unit(holiday_id)
    case holiday_id
    when 2,3,7
      "次"
    when 5,16,17,18
      "小时"
    else
      "天"
    end

  end

  def unit
    self.class.unit(self.id)
  end

end
