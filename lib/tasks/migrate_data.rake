namespace :migrate_data do
  desc "sys the tbldaytype to spec_days"
  task spec_days: :environment do
    ActiveRecord::Base.connection.execute(%{truncate spec_days; })
    #ActiveRecord::Base.connection.execute(%{insert into spec_days(sdate,is_workday,comment) select flddate,if(type>0,1,0),comment from tbldaytype; })

    CharesDatabase::Tbldaytype.find_each do |item|
      SpecDay.create(sdate:item.flddate, is_workday: item.type>0 ? true : false,comment: item.comment)
    end
  end

  desc "sys the tbldepartment to departments"
  task departments: :environment do
    #ActiveRecord::Base.connection.execute(%{truncate departments; })
    CharesDatabase::Tbldepartment.sys_departments
  end

  desc "sys the tblemployee to departments"
  task users: :environment do
    #ActiveRecord::Base.connection.execute(%{truncate users; })
    #ActiveRecord::Base.connection.execute(%{insert into users(uid,user_name,email,department,title,expire_date,dept_code,mgr_code)
                                          #select userId,name,email,department,title,expireDate,deptCode,mgrCode from tblemployee; })
    CharesDatabase::Tblemployee.sys_users

  end


  desc "sys episode"
  task episodes: :environment do
    #Rails.application.paths["app/models"].eager_load!
    holidays = Holiday.pluck(:id,:name)
    Episode.connection.execute("truncate episodes;")
    Episode.connection.execute("truncate approves;")

    CharesDatabase::TblEpisode.find_each do |item|
      holiday = holidays.rassoc(item.type == "产假" ? "产假/产检假" : item.type)
      user = User.find(item.userId)
      approve_user = User.find(item.approvedBy) if item.approvedBy
      e = Episode.create!(user_id: item.userId,holiday_id: holiday.first,start_date: item.startDate, end_date: item.endDate, comment: item.comments || holiday.last,state: item.approvedBy.present?,title: user.title,total_time: '暂无') #,approved_by: item.approvedBy, approved_time: item.approvedDate  )
      Approve.create!(user_id: item.approvedBy,user_name: approve_user.try(:user_name),updated_at: item.approvedDate,created_at: item.approvedDate,episode_id: e.id,state: e.state)

    end
  end


  #把batch_size 设置为2000，即大于该表的数量，因为该表没有主键，小于表行数量时可能会丢失一些数据
  desc 'sys journals'
  task journals: :environment do
    Journal.connection.execute("truncate journals;")
    CharesDatabase::Tbljournal.find_each(batch_size: 5000) do |item|
      Journal.create!(user_id: item.uid,update_date: item.updateDate, check_type: item.tp, description: item.cmmt, dval: item.dval)
    end
  end

  #select b.email,min(checktime) checkin,max(checktime) checkout from checkinout a inner join userinfo b on a.userid=b.userid  where a.userid=91 and a.checktime > '2015-01-04' and a.checktime < '2015-01-05' group by a.userid
  desc 'sys checkinout'
  task checkinouts: :environment do

    Checkinout.connection.execute("truncate checkinouts;")
    #CharesDatabase::TblCheckinout
    #["userId", "recDate", "checkin", "checkout", "refTime"]
    CharesDatabase::Tblcheckinout.where(["recDate > ?",'2015']).each do |item|
      Checkinout.create(rec_date: item.recDate,user_id: item.userId ,checkin: item.checkin,checkout: item.checkout,ref_time: item.refTime)
    end
    #unless defined?(EmailCheck)
    #  class EmailCheck < ActiveRecord::Base
    #    self.table_name = 'checkinout'
    #    establish_connection(:kaoqing_database)
    #  end
    #end
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
    Rake::Task["migrate_data:episodes"].invoke
    Rake::Task["migrate_data:journals"].invoke
    Rake::Task["migrate_data:checkinouts"].invoke
    Rake::Task["migrate_data:year_infos"].invoke
  end

  #----------------------------------
  #导入数据，基础假及消耗假期
  #yearinfo
  #0 工号,
  #1 2015年剩余倒休
  #2 工作室剩余贡献分
  #3 2015年剩余年假
  #4 15年剩余带薪病假
  #5 2015年带薪事假
  #journal
  #6 产假
  #7 产检
  #8 陪产假
  #9 婚假
  #10 丧假
  #11 出差
  #12 迟到
  #13 早退
  #14 漏打卡
  #15 病假
  #16 事假
  #

  desc '导入数据，基础假及消耗假期,需传入文件名'
  task :import_data,[:file_name] =>  :environment do |t,args|
    args.with_defaults(file_name: 'yearinfo.csv')
    File.readlines(args.file_name).each do |row|
      _values = row.rstrip.split(",").collect!{|item|(item[/-?\d+/].to_f*10).round}

      _uid = _values.first/10

      _year_info = YearInfo.find_or_initialize_by(user_id: _uid,year:'2015')
      _year_info.switch_leave = _values[1]
      _year_info.ab_point = _values[2]
      _year_info.year_holiday = _values[3]
      _year_info.sick_leave = _values[4]
      _year_info.affair_leave = _values[5]

      _year_info.save!

      _journal = Journal.find_or_create(user_id: _uid,update_date: '2015-02-30',check_type: 13 )
      _journal.dval = _values[6] + _values[7]


      _user.update_attributes()
      puts _values.inspect
      #user = User.find(1416)

    end

  end


end
