# == Schema Information
#
# Table name: checkinout
#
#  id         :integer          not null, primary key
#  userid     :integer          not null
#  checktime  :datetime         not null
#  checktype  :string(5)        default(""), not null
#  verifycode :integer          not null
#  SN         :integer
#  sensorid   :string(5)
#  WorkCode   :string(20)
#  Reserved   :string(20)
#  sn_name    :string(40)
#

module CharesDatabase
  #class Tblcheckinout < ThirdTable
  class Checkinout < ExternalTable
    #self.primary_key = 'uid'
    self.table_name = 'checkinout'

    #2015-04-02 13:30 javy_liu upgrade to multi days
    def self.sys_data(from,to,unames = nil )
      from = Date.yesterday unless from
      to = Date.today unless to

      user_id_emails = User.not_expired.where('email is not null').where(unames.blank? ? nil : ["user_name in (?)",unames.split(",")]).pluck(:uid,:email)

      sql = if unames.blank?
              ["select b.email,group_concat(checktime) check_times,date(checktime) rec_date from checkinout a inner join userinfo b on a.userid=b.userid where a.checktime > ? and a.checktime < ? group by a.userid,rec_date",from,to]
            else
              ["select b.email,group_concat(checktime) check_times,date(checktime) rec_date from checkinout a inner join userinfo b on a.userid=b.userid where b.email in (?) and a.checktime > ? and a.checktime < ? group by a.userid,rec_date",user_id_emails.transpose.last,from,to]
            end

      email_checks = self.find_by_sql(sql)

      email_checks.each do |item|
        next if item.email.blank?
        ck_times = item.check_times.split(',')
        checkin = ck_times.min
        checkout = ck_times.max
        ref_time = nil
        #设置ref_time(参考打卡时间)
        if checkin < (_date = "#{item.rec_date} 05:00:00")
          normal_ctimes = ck_times.partition{|ct| ct < _date}.last
          ref_time = normal_ctimes.sort.first
        end
        user_id = user_id_emails.rassoc(item.email.strip).try(:first)
        _ck = ::Checkinout.find_or_initialize_by(rec_date: item.rec_date,user_id: user_id)
        _ck.checkin = checkin
        _ck.checkout = checkout
        _ck.ref_time = ref_time
        Rails.logger.info "SysCheckout: #{item.email} #{_ck.inspect}"

        _ck.save!

        #::Checkinout.create!(rec_date: item.rec_date,user_id: user_id ,checkin: checkin,checkout: checkout,ref_time: ref_time)
      end

    end
  end
end
