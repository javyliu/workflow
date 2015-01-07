class DailyMailJob < ActiveJob::Base
  queue_as :default

  #TODO: need add workday judge,if not workday don't send email
  #need use before_action
  def perform(*args)
    #leader with employees in user_ids
    #has attributes uid,user_ids,atten_rule
    leaders_hash = User.find_by_sql(%{select b.atten_rule,b.mgr_code uid,GROUP_CONCAT(a.uid) user_ids
    from users a INNER JOIN departments b on a.dept_code = b.`code` where a.expire_date is NULL and a.mgr_code is NULL and b.atten_rule is not NULL GROUP BY b.`code`  UNION
    select b.atten_rule,a.mgr_code uid,GROUP_CONCAT(a.uid) user_ids
    from users a INNER JOIN departments b on a.dept_code = b.`code` where a.expire_date is NULL and a.mgr_code is not NULL and b.atten_rule is not NULL GROUP BY a.mgr_code;
    }).group_by(&:uid)

    #构建每一封邮件并发出去
    leaders_hash.map{|k,v| [k,v.first.atten_rule,v.inject([]){|uids,item|uids + item.user_ids.split(",")}]}.each do |leader_user_id,atten_rule,uids|
      Usermailer.daily_kaoqing(leader_user_id,atten_rule,uids,date: Date.today).deliver_now
    end
  end
end
