class Journal < ActiveRecord::Base
  #年假，带薪病假，事假，用的是正值，其它是无符号值
  #迟到，早退，漏打卡按次计
  belongs_to :user
  #数组说明
  #0：标识
  #1:数据库对应字id
  #2：中文描述
  #4：计数单位
  #6：标头css类
  #7：数据库存储对应倍数，（小时及天须乘以10存储)
  CheckType = [
    ['c_aff_later',1, '迟到','次','group_chi',1],
    ['c_aff_leave',2,'早退','次','group_chi',1],
    ['c_aff_absent',3,'旷工','天','group_tian',1],
    ['c_aff_forget_checkin',4,'漏打卡','次','group_chi',1],
    ['c_aff_holiday_year',5,'年假','天','group_tian',10],
    ['c_aff_sick',6,'病假','天','group_tian',10],
    ['c_aff_persion_leave',7,'事假','天','group_tian',10],
    ['c_aff_switch_leave',8,'加班时长','小时','group_shi',10],
    ['c_aff_a_points',9,'A贡献分','小时','group_shi',10],
    ['c_aff_spec_appr',10,'特批','','group_te',0],
    ['c_aff_holiday_salary',11,'带薪事假','天','group_tian',10],
    ['c_aff_switch_time',12,'倒休','小时','group_shi',10],
    ['c_aff_holiday_maternity',13,'产假','天','group_tian',10],
    ['c_aff_holiday_acco_maternity',14,'陪产假','天','group_tian',10],
    ['c_aff_holiday_marriary',15,'婚假','天','group_tian',10],
    ['c_aff_holiday_funeral',16,'丧假','天','group_tian',10],
    ['c_aff_sick_salary',17,'带薪病假','天','group_tian',10],
    ['c_aff_holiday_trip',18,'出差','天','group_tian',10],
    ['c_aff_nursing_later',19,'哺乳期晚来1小时','次','group_chi',1],
    ['c_aff_nursing_leave',20,'哺乳期早走1小时','次','group_chi',1],
    ['c_aff_b_points',21,'B贡献分','小时','group_shi',10],
    ['c_aff_others',22,'其它','','group_qi',-1]
  ]

  MailDecType= [
    ['c_aff_absent','a'],
    ['c_aff_holiday_salary','b'],
    ['c_aff_holiday_maternity','c'],
    ['c_aff_holiday_acco_maternity','d'],
    ['c_aff_holiday_marriary','e'],
    ['c_aff_holiday_funeral','f'],
    ['c_aff_sick_salary','g'],
    ['c_aff_holiday_trip','h'],
    ['c_aff_nursing_later','i'],
    ['c_aff_nursing_leave','j']
  ]

  def self.cktype_from_key(key)
    CheckType.assoc(MailDecType.rassoc(key.downcase).first)
  end

  def self.mail_dec_identities
    @mail_dec_identities ||= MailDecType.transpose.first
  end


end
