class SysUserJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    #密码表的生成时间
    #_c_time = File.ctime("/root/sh/mailpasswd.txt").to_date
    #_today = Date.today
    #如果文件的更改时间不是周一，则同步用户密码，
    #只有在周四及以后才会修改密码 2015-03-26 10:47 javy_liu
    #need_change_pwd = Date.today.wday >= 4

    #2015-06-05 13:53 javy read time from /root/sh/fixtime
    change_pwd_date =  Rails.cache.fetch("cp_time_#{File.mtime("/root/sh/fixtime").to_s(:number)}") do
      File.open("/root/sh/fixtime").read.force_encoding("gbk").encode("utf-8").scan(/[-\d]+/)
    end

    need_change_pwd = change_pwd_date.include?(Date.today.to_s)

    Rails.logger.info  "sys user department..."
    CharesDatabase::Tbldepartment.sys_departments
    Rails.logger.info  "sys user pwd..."
    CharesDatabase::Tblemployee.sys_users(need_change_pwd)
  end
end
