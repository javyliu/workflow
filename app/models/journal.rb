class Journal < ActiveRecord::Base
  #年假，带薪病假，事假，用的是正值，其它是无符号值
  #迟到，早退，漏打卡按次计
  belongs_to :user
  include JavyTool::Csv
  validates :check_type, presence: true
  validates :user_id, presence: true
  validates :update_date, presence: true
  #用于数据手动组装,避免n+1
  #has_one :checkinout #, -> {where(user_id: self.user_id,rec_date: self.update_date)}
  #数组说明
  #0：标识
  #1:数据库对应字id
  #2：中文描述
  #3：计数单位
  #4：标头css类
  #5：是否允许负数
  #6：与holiday 的id 对应值
  #7：数据库存储对应倍数，（小时及天须乘以10存储)

  #holiday
  #1,病假
  #2,哺乳期晚到1小时
  #3,哺乳期早走1小时
  #4,产假/产检假
  #5,倒休
  #6,事假
  #7,漏打卡
  #8,带薪事假
  #9,带薪病假
  #10,年假
  #11,陪产假
  #12,婚假
  #13,丧假
  #14,外出
  #15,出差
  #16,特批
  #17,加班
  CheckType = [
    ['c_aff_later',1, '迟到','次','group_chi',false,nil,1],
    ['c_aff_leave',2,'早退','次','group_chi',false,nil,1],
    ['c_aff_absent',3,'旷工','天','group_tian',false,nil,1],
    ['c_aff_forget_checkin',4,'漏打卡','次','group_chi',false,7,1],
    ['c_aff_holiday_year',5,'年假','天','group_tian',false,10,10],
    ['c_aff_sick',6,'病假','天','group_tian',false,1,10],
    ['c_aff_persion_leave',7,'事假','天','group_tian',false,6,10],
    ['c_aff_switch_leave',8,'加班时长','小时','group_shi',false,17,10],
    ['c_aff_a_points',9,'A贡献分','小时','group_shi',true,nil,10],
    ['c_aff_spec_appr',10,'特批','','group_te',false,nil,0],
    ['c_aff_holiday_salary',11,'带薪事假','天','group_tian',false,8,10],
    ['c_aff_switch_time',12,'倒休','小时','group_shi',false,5,-10],
    ['c_aff_holiday_maternity',13,'产假 产检假','天','group_tian',false,4,10],
    ['c_aff_holiday_acco_maternity',14,'陪产假','天','group_tian',false,11,10],
    ['c_aff_holiday_marriary',15,'婚假','天','group_tian',false,12,10],
    ['c_aff_holiday_funeral',16,'丧假','天','group_tian',false,13,10],
    ['c_aff_sick_salary',17,'带薪病假','天','group_tian',false,9,10],
    ['c_aff_holiday_trip',18,'出差','天','group_tian',false,15,10],
    ['c_aff_nursing_later',19,'哺乳期晚来1小时','次','group_chi',false,2,1],
    ['c_aff_nursing_leave',20,'哺乳期早走1小时','次','group_chi',false,3,1],
    ['c_aff_b_points',21,'B贡献分','小时','group_shi',true,16,10],
    ['c_aff_outing',23,'外出','天','group_tian',false,14,10],
    ['c_aff_others',22,'其它','','group_qi',false,nil,-1]
  ]

  #2015-04-02 10:18 无用代码
  #UserCheckTypeIds = %w[5 8 9 11 12 17 21]
  #用于其它中的别名对应
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
    ['c_aff_nursing_leave','j'],
    ['c_aff_outing','l']
  ]

  #得到类别标识，用于邮件回复中通过字符返回标识符
  def self.cktype_from_key(key)
    CheckType.assoc(MailDecType.rassoc(key.downcase).first)
  end

  #用于邮件显示中在“其它”栏中回复的标识符，主要用于邮件中说明的展示
  def self.mail_dec_identities
    @mail_dec_identities ||= MailDecType.transpose.first
  end


end
