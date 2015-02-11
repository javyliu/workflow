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
types = %w{病假 哺乳期晚到1小时 哺乳期早走1小时 产假 倒休 事假 漏打卡 带薪事假 带薪病假 年假 陪产假 婚假 丧假}
Holiday.create(types.map{|item|{name: item}})
titles =[
  ['c_line_num','行号'],
  ['c_dept_name','部门'],
  ['c_user_name','姓名'],
  ['c_holiday_year','剩余年假'],
  ['c_sick_leaver','剩余带薪病假'],
  ['c_ab_point','累计贡献分'],
  ['c_switch_leave','累计倒休'],
  ['c_checkin','签入'],
  ['c_checkout','签出'],
  ['c_later_time','迟到时长'],
  ['c_leave_time','早退时长'],
  ['c_ref_cmd','参考意见'],
  ['c_a_point','A'],
  ['c_b_point','B'],
  ['c_switch_hours','加班时长'],
  ['c_aff_points','确认贡献分'],
  ['c_aff_switch_leave','确认加班时长'],
  ['c_aff_later','迟到'],
  ['c_aff_leave','早退'],
  ['c_aff_absent','旷工'],
  ['c_aff_forget_checkin','漏打卡'],
  ['c_aff_holiday_year','年假'],
  ['c_aff_sick','病假'],
  ['c_aff_persion_leave','事假'],
  ['c_aff_spec_appr','特批'],
  ['c_aff_holiday_salary','带薪事假'],
  ['c_aff_switch_time','倒休'],
  ['c_aff_holiday_maternity','产假'],
  ['c_aff_holiday_acco_maternity','陪产假'],
  ['c_aff_holiday_marriary','婚假'],
  ['c_aff_holiday_funeral','丧假']
]
ReportTitle.create(titles.map{|name,des| {name: name,des: des}})
rules = [
  ['ab_point4_qiLe','AB分无倒休-奇乐',%w[1 2 3 4 5 6 8 9 10 11 12 13 14  16 18 19 20 21 22 23 24 25 26,27,28,29,30,31,32],0,30],
  ['ab_point','AB分工作时间',%w[1 2 3 4 5 6  8 9   12 13 14  16  18 19 20 21 22 23 24 25 26,27,28,29,30,31,32],0,30],
  ['flexible_working_time','弹性工作时间',%w[1 2 3 4 5  7 8 9   12   15  17 18 19 20 21 22 23 24 25 26,27,28,29,30,31,32],0,60],
  ['platform','固定工作时间',%w[1 2 3 4 5  7 8 9   12   15  17 18 19 20 21 22 23 24 25 26,27,28,29,30,31,32],"9:01-18:00",60],
]

AttendRule.create(rules.map{|rule_name,des,title_ids,time_range,min_unit| {name: rule_name, description: des, title_ids: title_ids,time_range: time_range,min_unit: min_unit}})

OaConfig.create(
  [{key: "prompt_max_times",des: "最多提醒次数",value: "10"},
  {key: "end_year_time",des: "年度假期截止日",value: "2014-02-18"}]
)
