module CharesDatabase
  #class Tblcheckinout < ThirdTable
  class Checkinout < ExternalTable
    #self.primary_key = 'uid'
    self.table_name = 'checkinout'

    #2015-04-02 13:30 javy_liu upgrade to multi days
    def self.sys_data(from,to )
      from = Date.yesterday unless from
      to = Date.today unless to

      email_checks = self.find_by_sql(["select b.email,group_concat(checktime) check_times,date(checktime) rec_date from checkinout a inner join userinfo b on a.userid=b.userid  where a.checktime > ? and a.checktime < ? group by a.userid,rec_date",from,to])

      user_id_emails = User.where(email: email_checks.map{|item|item.email}).pluck(:uid,:email)
      email_checks.each do |item|
        ck_times = item.check_times.split(',')
        checkin = ck_times.min
        checkout = ck_times.max
        ref_time = nil
        #设置ref_time(参考打卡时间)
        if checkin < (_date = "#{item.rec_date} 05:00:00")
          normal_ctimes = ck_times.partition{|ct| ct < _date}.last
          ref_time = normal_ctimes.sort.first
        end
        user_id = user_id_emails.rassoc(item.email).try(:first)
        next if ::Checkinout.where(rec_date: item.rec_date,user_id: user_id).count() > 0
        ::Checkinout.create!(rec_date: item.rec_date,user_id: user_id ,checkin: checkin,checkout: checkout,ref_time: ref_time)
      end

    end
  end
end
