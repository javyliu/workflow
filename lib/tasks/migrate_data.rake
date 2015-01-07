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


  #把batch_size 设置为2000，即大于该表的数量，因为该表没有主键，小于表行数量时可能会丢失一些数据
  desc 'sys journals'
  task journals: :environment do
    Journal.connection.execute("truncate journals;")
    CharesDatabase::Tbljournal.find_each(batch_size: 2000) do |item|
      Journal.create!(user_id: item.uid,update_date: item.updateDate, check_type: item.tp, description: item.cmmt, dval: item.dval)
    end
  end

  #select b.email,min(checktime) checkin,max(checktime) checkout from checkinout a inner join userinfo b on a.userid=b.userid  where a.userid=91 and a.checktime > '2015-01-04' and a.checktime < '2015-01-05' group by a.userid
  desc 'sys checkinout'
  task checkinouts,:enviroment do

    class EmailCheck < ActiveRecord::Base
      self.table_name = 'checkinout'
      establish_connection(:kaoqing_database)
    end
    email_checks = EmailCheck.find_by_sql(["select b.email,min(checktime) checkin,max(checktime) checkout from checkinout a inner join userinfo b on a.userid=b.userid  where a.checktime > '?' and a.checktime < '?' group by a.userid",Date.yesterday,Date.today])

    user_id_emails = User.where(email: email_checks.map{|item|item.email}).pluck(:id,:email)
    email_checks.each do |item|
      checkinout.create(user_id: user_id_emails.rassoc(item.email).try(:first),checkin: item.checkin,checkout: item.checkout,ref_time: item.ref_time)
    end

  end

  desc 'sys year_infos'
  task year_infos: :environment do
    Journal.connection.execute("truncate year_infos;")
    CharesDatabase::Tblyearinfo.find_each do |item|
      YearInfo.create!(user_id: item.uid,year: item.year, year_holiday: item.yearHolody, sick_leave: item.sickLeave, affair_leave: item.affairLeave,switch_leave: item.switchLeave,ab_point:item.aPoint)
    end
  end

  desc "sys all tables"
  task all: :environment do
    Rake::Task["migrate_data:spec_days"].invoke
    Rake::Task["migrate_data:departments"].invoke
    Rake::Task["migrate_data:users"].invoke
  end
end
