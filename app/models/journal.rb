class Journal < ActiveRecord::Base
  #年假，带薪病假，事假，用的是正值，其它是无符号值
  #迟到，早退，漏打卡按次计
  CheckType = [
    ["c_aff_later",1, "迟到"],
    ["c_aff_leave",2,"早退"],
    ["c_aff_absent",3,"旷工"],
    ["c_aff_forget_checkin",4,"漏打卡"],
    ["c_aff_holiday_year",5,"年假"],
    ["c_aff_sick",6,"病假"],
    ["c_aff_persion_leave",7,"事假"],
    ["c_aff_switch_leave",8,"倒休"],
    ["c_aff_points",9,"贡献分"],
    ["c_aff_spec_appr",10,"特批"]
  ]

end
