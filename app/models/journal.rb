class Journal < ActiveRecord::Base
  #年假，带薪病假，事假，用的是正值，其它是无符号值
  CheckType = [
    ["c_aff_later", "迟到",1],
    ["c_aff_leave","早退",2],
    ["c_aff_absent","旷工",3],
    ["c_aff_forget_checkin","漏打卡",4],
    ["c_aff_holiday_year","年假",5],
    ["c_aff_sick","病假",6],
    ["c_aff_persion_leave","事假",7],
    ["c_aff_switch_leave","倒休",8],
    ["c_aff_points","贡献分",9],
    ["c_aff_spec_appr","特批",10]
  ]

end
