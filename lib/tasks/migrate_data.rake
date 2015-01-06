namespace :migrate_data do
  desc "sys the tbldaytype to spec_days"
  task spec_days: :environment do
    ActiveRecord::Base.connection.execute(%{truncate spec_days; })
    ActiveRecord::Base.connection.execute(%{insert into spec_days(sdate,is_workday,comment) select flddate,if(type>0,1,0),comment from tbldaytype; })
  end

  desc "sys the tbldepartment to departments"
  task departments: :environment do
    ActiveRecord::Base.connection.execute(%{truncate departments; })
    ActiveRecord::Base.connection.execute(%{insert into departments(code,name,atten_rule,mgr_code,admin) select deptCode,deptName,attenRules,mgrCode,admin from tbldepartment; })
  end

  desc "sys the tblemployee to departments"
  task users: :environment do
    ActiveRecord::Base.connection.execute(%{truncate users; })
    ActiveRecord::Base.connection.execute(%{insert into users(uid,user_name,email,department,title,expire_date,dept_code,mgr_code)
                                          select userId,name,email,department,title,expireDate,deptCode,mgrCode from tblemployee; })
  end


  desc "sys episode"
  task episodes: :environment do
    #Rails.application.paths["app/models"].eager_load!
    holidays = Holiday.pluck(:id,:name)
    Episode.connection.execute("truncate episodes;")
    CharesDatabase::Tblepisode.find_each do |item|
      Episode.create(user_id: item.userId,holiday_id: holidays.rassoc(item.type).try(:first),start_date: item.startDate, end_date: item.endDate, comment: item.comments,approved_by: item.approvedBy, approved_time: item.approvedDate  )
    end
  end

  desc "sys all tables"
  task all: :environment do
    Rake::Task["migrate_data:spec_days"].invoke
    Rake::Task["migrate_data:departments"].invoke
    Rake::Task["migrate_data:users"].invoke

  end
end
