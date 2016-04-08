# == Schema Information
#
# Table name: holidays
#
#  id   :integer          not null, primary key
#  name :string(255)
#

class Holiday < ActiveRecord::Base
  has_many :episodes

  #添加或更新假期需要重启应用
  ALL = self.all.to_a
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
  #18,误餐及交通补助(仅限经理级)
  #19迟到早退特批假
  def self.unit(holiday_id)
    Journal::CheckType.detect{|item|item[6] == holiday_id}.try(:[],3)
    #case holiday_id
    #when 2,3,7
    #  "次"
    #when 5,16,17,18
    #  "小时"
    #else
    #  "天"
    #end

  end

  def unit
    self.class.unit(self.id)
  end

  def self.dept_holiday(ids)
    ALL.select{|item| item.id.in?(ids)}
  end

end
