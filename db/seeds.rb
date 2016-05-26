# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Holiday.connection.execute("truncate holidays")
Holiday.connection.execute("truncate report_titles")
Holiday.connection.execute("truncate attend_rules")
Holiday.connection.execute("truncate oa_configs")
types = %w{病假 哺乳期晚到1小时 哺乳期早走1小时 产假/产检假 倒休 事假 漏打卡 带薪事假 带薪病假 年假 陪产假 婚假 丧假 外出 出差 特批 加班 误餐及交通补助(仅限经理级) 迟到早退特批假}
Holiday.create(types.map{|item|{name: item}})
titles =[
  ['c_line_num','行号',1],
  ['c_dept_name','部门',50],
  ['c_user_name','姓名',2],
  ['c_holiday_year','剩余年假',41],
  ['c_sick_leaver','剩余带薪病假',42],
  ['c_ab_point','剩余贡献分',43],
  ['c_switch_leave','累计倒休',44],
  ['c_checkin','签入',45],
  ['c_checkout','签出',46],
  ['c_later_time','迟到时长',47],
  ['c_leave_time','早退时长',48],
  ['c_ref_cmd','参考意见',3],
  ['c_a_point','A  参考',40],
  ['c_b_point','B  参考',40],
  ['c_switch_hours','加班时长',41],
  ['c_aff_a_points','确认A分',4],
  ['c_aff_b_points','确认B分',5],
  ['c_aff_switch_leave','确认加班时长',6],
  ['c_aff_later','迟到',9],
  ['c_aff_leave','早退',10],
  ['c_aff_absent','旷工',11],
  ['c_aff_forget_checkin','漏打卡',12],
  ['c_aff_holiday_year','年假',16],
  ['c_aff_sick','病假',17],
  ['c_aff_persion_leave','事假',18],
  ['c_aff_spec_appr','特批描述',29],
  ['c_aff_holiday_salary','带薪事假',19],
  ['c_aff_switch_time','倒休',7],
  ['c_aff_holiday_maternity','产假  产检假',20],
  ['c_aff_holiday_acco_maternity','陪产假',21],
  ['c_aff_holiday_marriary','婚假',22],
  ['c_aff_holiday_funeral','丧假',23],
  ['c_aff_sick_salary','带薪病假',24],
  ['c_aff_holiday_trip','出差',25],
  ['c_aff_nursing_later','哺乳期晚来1小时',13],
  ['c_aff_nursing_leave','哺乳期早走1小时',14],
  ['c_aff_outing','外出',29],
  ['c_aff_spec_appr_holiday','休假特批',6],
  ['c_aff_spec_appr_later','迟到早退特批',7],
  ['c_aff_others','其它',30],
  ['c_aff_count','工作点数',6 ],
  ['c_month_count','本月点数',40 ],
  ['c_month_later_or_absent','月迟到早退特批',41]
]
ReportTitle.create(titles.map{|name,des,ord| {name: name,des: des,ord: ord}})
rules = [
 ['ab_point4_qiLe','AB分无倒休-奇乐',[1,2,3,4,5,6,8,9,10,11,12,13,14,16,17,19,20,21,22,23,24,25,27,29,30,31,32,33,34,35,36,37,38,39,41,42,43],0,30],
 ['ab_point','AB分工作时间',[1,2,3,4,5,6,8,9,12,13,14,16,17,19,20,21,22,23,24,25,27,29,30,31,32,33,34,35,36,37,38,39,41,42,43],0,30],
 ['flexible_working_time','弹性工作时间',[1,2,3,4,5,7,8,9,12,15,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,41,42,43],0,60],
 ['platform','固定工作时间',[1,2,3,4,5,7,8,9,12,15,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,41,42,43],"9:01-18:00",60],
 ['flexible_no_switch','弹性工作时间无倒休',[1,2,3,4,5,8,9,12,15,18,19,20,21,22,23,24,25,26,27,29,30,31,32,33,34,35,36,37,41,42,43],0,60]
 ]

AttendRule.create(rules.map{|rule_name,des,title_ids,time_range,min_unit| {name: rule_name, description: des, title_ids: title_ids,time_range: time_range,min_unit: min_unit}})

OaConfig.create(
  [
    {key: "prompt_max_times",des: "最多提醒次数",value: "1"},
    {key: "end_year_time",des: "年度假期截止日",value: "2015-02-18"},
    {key: "affair_leave_days",des: "带薪事假天数",value: "0"},
    {key: "sick_leave_days",des: "带薪病假天数",value: "3"},
    {key: "start_day_of_month",des: "月考勤开始日",value: "26"},
    {key: "end_day_of_month",des: "月考勤截止日",value: "25"}
  ]
)
