# == Schema Information
#
# Table name: journals
#
#  id          :integer          not null, primary key
#  user_id     :string(20)
#  update_date :date
#  check_type  :integer
#  description :string(255)
#  dval        :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Journal < ActiveRecord::Base
  #年假，带薪病假，事假，用的是正值，其它是无符号值
  #迟到，早退，漏打卡按次计
  belongs_to :user
  include JavyTool::Csv
  validates :check_type, presence: true
  validates :user_id, presence: true
  validates :update_date, presence: true
  scope :grouped_journals, ->{ select("user_id,check_type,sum(dval) dval,year(update_date) year").where(["check_type in (?) and update_date > ?",Journal::UserCheckTypeIds,OaConfig.setting(:end_year_time)]).group(:user_id,:check_type,:year).order("year desc")}

  #按月统计的数值，本月点数(26)，迟到早退特批（25）
  scope :month_journals, ->{ select("user_id,check_type,sum(dval) dval").where(check_type:[25,26]).group(:user_id,:check_type) }

  #2016-04-17
  def spec_appr_holiday
    Journal.find_by(user_id: self.user_id, update_date: self.update_date,check_type: 24)
  end



  #用于数据手动组装,避免n+1
  #has_one :checkinout #, -> {where(user_id: self.user_id,rec_date: self.update_date)}
  #数组说明
  #0：标识
  #1: 数据库对应字id
  #2：中文描述
  #3：计数单位
  #4：标头css类
  #5：是否允许负数
  #6：与holiday 的id 对应值,用于判断某异常考勤是否需要假单
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
  #18,误餐及交通补助(仅限经理级)
  #19,迟到早退特批假
  CheckType = [
    ['c_aff_later',1, '迟到','次','group_chi',false,nil,1],
    ['c_aff_leave',2,'早退','次','group_chi',false,nil,1],
    ['c_aff_absent',3,'旷工','天','group_tian',false,nil,1],
    ['c_aff_forget_checkin',4,'漏打卡','次','group_chi',false,7,1],
    ['c_aff_holiday_year',5,'年假','天','group_tian',false,10,10],
    ['c_aff_sick',6,'病假','天','group_tian',false,1,10],
    ['c_aff_persion_leave',7,'事假','天','group_tian',false,6,10],
    ['c_aff_switch_leave',8,'延时下班时长','小时','group_shi',false,17,10],
    ['c_aff_a_points',9,'A贡献分','小时','group_shi',false,nil,10],
    ['c_aff_spec_appr',10,'特批描述','','group_te',false,nil,0],
    ['c_aff_holiday_salary',11,'带薪事假','天','group_tian',false,8,10],
    #['c_aff_switch_time',12,'酌情倒休时长','小时','group_shi',false,5,-10],
    ['c_aff_switch_time',12,'酌情倒休时长','小时','group_shi',false,nil,-10],
    ['c_aff_holiday_maternity',13,'产假 产检假','天','group_tian',false,4,10],
    ['c_aff_holiday_acco_maternity',14,'陪产假','天','group_tian',false,11,10],
    ['c_aff_holiday_marriary',15,'婚假','天','group_tian',false,12,10],
    ['c_aff_holiday_funeral',16,'丧假','天','group_tian',false,13,10],
    ['c_aff_sick_salary',17,'带薪病假','天','group_tian',false,9,10],
    ['c_aff_holiday_trip',18,'出差','天','group_tian',false,15,10],
    ['c_aff_nursing_later',19,'哺乳期晚来1小时','次','group_chi',false,2,1],
    ['c_aff_nursing_leave',20,'哺乳期早走1小时','次','group_chi',false,3,1],
    ['c_aff_b_points',21,'B贡献分','小时','group_shi',false,nil,10],
    ['c_aff_outing',23,'因公外出','天','group_tian',false,14,10],
    ['c_aff_spec_appr_holiday',24,'休假特批','小时','group_shi',false,nil,-10],
    ['c_aff_spec_appr_later',25,'迟到早退特批','次','group_chi',false,19,1],
    ['c_aff_count',26,'工作点数','点','group_shi',false,nil,1],
    ['c_aff_others',22,'其它','','group_qi',false,nil,-1]#,
    #['c_aff_others',27,'误餐及交通补助(仅限经理级)','小时','group_shi',false,18,10]
  ]

  #TODO: 把cktype与holiday统一起来放到holiday表中，更新现在的ck_type

  UserCheckTypeIds = [5,8,9,11,12,17,21,24]
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

  #返回一个任意日期的考勤周期数组[start_date,end_date]
  #is_for_validate: 是否用于验证截止日下一天是否可编辑上月考勤(当date为today时，使用 .between()方法)
  #考勤截止日的下一天仍可更新本周期考勤
  def self.count_time_range(date: Date.today, is_for_validate: false )
    start_date = OaConfig.setting(:start_day_of_month).to_i
    end_date = OaConfig.setting(:end_day_of_month).to_i
    date = date.respond_to?(:day) ? date : Date.parse(date)
    day = date.day

    if is_for_validate
      end_date = end_date+1
      #开始时间比结束时间大1天，则要调整一下开始时间，以避免出现不能确认考勤的情况
      start_date = end_date  if (start_date - end_date) >= 1
    end


    if day > end_date
      [date.change(day: start_date),date.next_month.change(day: end_date)]
    else
      [date.last_month.change(day: start_date),date.change(day: end_date )]
    end
  end

  def ck_type
    @_ck_type ||= Journal::CheckType.rassoc(self.check_type)
  end

  #用于邮件显示中在“其它”栏中回复的标识符，主要用于邮件中说明的展示
  def self.mail_dec_identities
    @mail_dec_identities ||= MailDecType.transpose.first
  end


end
