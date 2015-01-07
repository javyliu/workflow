module CharesDatabase
  #class Tblcheckinout < ThirdTable
  class Tblcheckinout < ExternalTable
    #self.primary_key = 'uid'
    self.table_name = 'checkinout'

    def self.sys_data(from= Date.yesterday,to= Date.today)
      email_checks = self.find_by_sql(["select b.email,group_concat(checktime) check_times from checkinout a inner join userinfo b on a.userid=b.userid  where a.checktime > ? and a.checktime < ? group by a.userid",from,to])

      user_id_emails = User.where(email: email_checks.map{|item|item.email}).pluck(:uid,:email)
      email_checks.each do |item|
        ck_times = item.check_times.split(',')
        checkin = ck_times.min
        checkout = ck_times.max
        ref_time = nil
        #设置ref_time(参考打卡时间)
        if checkin < (_date = "#{from} 05:00:00")
          normal_ctimes = ck_times.partition{|ct| ct < _date}.last
          ref_time = normal_ctimes.sort.first
        end
        Checkinout.create(rec_date: from,user_id: user_id_emails.rassoc(item.email).try(:first),checkin: checkin,checkout: checkout,ref_time: ref_time)
      end

    end
  end
end
