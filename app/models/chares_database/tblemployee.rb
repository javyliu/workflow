module CharesDatabase
  #2015-03-26 17:54 javy 在正式库中添加两个表
  class Tblemployee < ActiveRecord::Base
    self.table_name = 'tblemployee'
    self.primary_key = 'userId'

    StaticPwdUsers = %w{postmaster addressbak kjvv gamepipsender techadmin hwang yhzhao jcui cwu kjgao pippay pippay2 yiqing.chang x mzsq y yang.liu yongqing.liu yhrx qmliu}

    def self.sys_users(need_change_pwd=true,path="/root/sh/mailpasswd.txt")
      pwds = Hash[*YAML.load_file(path).split(/:|\s+/)]
      _date = Date.today
      #十天之内离职用户亦会同步，为了防止同步出错后第二天同步不能修复离职员工
      self.where("expireDate is null or expireDate >= date_sub(current_date(),interval '10 00' DAY_HOUR)").find_each do |item|
        #User.create!(uid: item.userId,user_name:item.name,email:item.email,department:item.department,expire_date:item.expireDate,dept_code:item.deptCode,mgr_code:item.mgrCode,title: item.title,onboard_date: item.onboardDate,regular_date: item.regularDate,password: '123123')
        u = User.find_or_initialize_by(uid: item.userId)
        u.expire_date=item.expireDate
        if u.expire_date && u.expire_date < _date
          Rails.logger.info { "-----------delete user :#{u.user_name}" }
          u.delete and next
        end
        u.user_name = item.name
        u.email=item.email
        #2015-12-29 部门字段已更新其意义为该用户可管理的部门，同步时不再同步
        #u.department=item.department
        u.dept_code=item.deptCode
        #2015-03-27 09:37 javy don't sys the mgrcode and department
        #u.mgr_code=item.mgrCode
        #2015-04-17 15:05 javy don't sys the title
        #u.title= item.title
        u.onboard_date= item.onboardDate
        u.regular_date= item.regularDate



        #有email的用户才会设置密码，否则不设
        if u.email
          _uname = u.email[/.*(?=@)/,0]
          unless StaticPwdUsers.include?(_uname)
            if u.new_record? || need_change_pwd
              u.password = pwds[_uname]
              u.remember_token_expires_at = nil
              u.remember_token            = nil
            end
          end
          #只有新用户才会无密码，所以在此初始化部分数据
          if u.password_digest.nil?
            u.password = '123123'
            u.title = item.title
            #初始化其year_info
            #u.create_last_year_info
          end
        end


        #u.password = u.email? ? (pwds[u.email[/.*(?=@)/,0]] || '123123') : '123123' #如果邮箱为空,或密码表为空，则设置密码为123123
        #puts u.inspect
        u.save!
        #更新基础假期表,每天都要计算一次

        calcute_year_info_data(u,_date)
        #如果用户的转正日期今日相等，则更新用户的基础带薪病假
        #if u.regular_date == _date
        #  u.last_year_info.update_attribute(:sick_leave, OaConfig.setting(:sick_leave_days).to_i * 10)
        #end
      end

      User.where("expire_date < current_date() ").delete_all
    end

    def self.calcute_year_info_data(user,date=Date.today)

      year_info = YearInfo.find_or_initialize_by(user_id: user.id,year: date.year)
      #如果用户的转正日期今日相等，则更新用户的基础带薪病假
      if user.regular_date == date
        year_info.sick_leave = OaConfig.setting(:sick_leave_days).to_i * 10
      end

      _total_years = (date - item.onboard_date).fdiv(365) rescue(Rails.logger.debug{"#{user.id} 司龄计算错误"};0)
      year_info.year_holiday = if _total_years < 1
                                 0
                               elsif _total_years < 2
                                 #最小单位为0.5天 * 10 为5
                                 (((item.onboard_date.end_of_year - item.onboard_date)*100.0)/365).round.to_f/2.tap{|t|Rails.logger.info("user_id: #{user.id}:#{t}")}
                               elsif _total_years <= 10
                                 50
                               elsif _total_years <= 20
                                 100
                               else
                                 150
                               end
      year_info.save!

    end

    #在users表中的直属管理者,指定经理等人的上一级管理者
    #CharesDatabase::Tblemployee::MgrCodeList.each{|item|puts item[0..3];puts User.where(uid: item[0..3]).update_all(mgr_code: item[4..-1]);puts item[4..-1]}
    #MgrCodeList=%w{
    #  10181009
    #  10541078
    #  10891078
    #  10971009
    #  10991021
    #  11381021
    #  11481009
    #  11541021
    #  11851042
    #  11981078
    #  12211551
    #  14161042
    #  14611011
    #  16081042
    #  17851551
    #  19971551
    #  20231551
    #  20681551
    #  20691551
    #  20971551
    #  21171551
    #  21681303
    #  21901551
    #}
  end
end
