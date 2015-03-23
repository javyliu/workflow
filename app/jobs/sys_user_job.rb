class SysUserJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    #密码表的生成时间
    _c_time = File.ctime("/root/sh/mailpasswd.txt").to_date
    _today = Date.toady
    #如果文件的更改时间不是周一，则同步用户，
    if (_c_time == _today  && _toady.wday != 1) || (_today == (_ctime+3.days))
        CharesDatabase::Tblemployee.sys_users
    end
  end
end
