module PwdDb
  class RedmineUser < ActiveRecord::Base
    self.table_name = 'users'
    establish_connection :redmine
  end

  class DailyReportUser < ActiveRecord::Base
    self.table_name = 'user'
    establish_connection :dailyreport
  end

  class PipGmUser < ActiveRecord::Base
    self.table_name = 'tbl_admin'
    establish_connection :pipgm
  end
end
