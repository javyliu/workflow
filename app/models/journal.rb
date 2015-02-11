class Journal < ActiveRecord::Base
  #年假，带薪病假，事假，用的是正值，其它是无符号值
  #迟到，早退，漏打卡按次计
  CheckType = [
    ["c_aff_later",1, "迟到","次",1],
    ["c_aff_leave",2,"早退","次",1],
    ["c_aff_absent",3,"旷工","天",1],
    ["c_aff_forget_checkin",4,"漏打卡","次",1],
    ["c_aff_holiday_year",5,"年假","天",10],
    ["c_aff_sick",6,"病假","天",10],
    ["c_aff_persion_leave",7,"事假","天",10],
    ["c_aff_switch_leave",8,"倒休","小时",10],
    ["c_aff_points",9,"贡献分","小时",10],
    ["c_aff_spec_appr",10,"特批","小时",-10],
    ['c_aff_holiday_salary',11,'带薪事假',"天",1],
    ['c_aff_switch_time',12,'倒休',"小时",10],
    ['c_aff_holiday_maternity',12,'产假',"天",1],
    ['c_aff_holiday_acco_maternity',13,'陪产假',"天",1],
    ['c_aff_holiday_marriary',14,'婚假',"天",1],
    ['c_aff_holiday_funeral',15,'丧假',"天",1],
    ['c_aff_holiday_funeral',16,'出差',"天",1]
  ]

end
