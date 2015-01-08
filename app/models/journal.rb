class Journal < ActiveRecord::Base
  CheckType = ["", "迟到", "早退", "旷工", "漏打卡", "年假", "病假", "事假", "倒休", "贡献分", "特批" ]
end
