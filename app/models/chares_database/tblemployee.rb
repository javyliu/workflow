module CharesDatabase
  #2015-03-26 17:54 javy 在正式库中添加两个表
  class Tblemployee < ActiveRecord::Base
    self.table_name = 'tblemployee'
    self.primary_key = 'userId'

    StaticPwdUsers = %w{postmaster addressbak kjvv gamepipsender techadmin hwang yhzhao jianguang.wu cwu kjgao pippay pippay2 yiqing.chang x mzsq y yang.liu yongqing.liu yhrx qmliu}

    def self.sys_users(need_change_pwd=true,path="/root/sh/mailpasswd.txt")
      pwds = Hash[*YAML.load_file(path).split(/:|\s+/)]
      _date = Date.today

      #十天之内离职用户亦会同步，为了防止同步出错后第二天同步不能修复离职员工
      #self.where("expireDate is null or expireDate >= date_sub(current_date(),interval '10 00' DAY_HOUR)").find_each do |item|
        #User.create!(uid: item.userId,user_name:item.name,email:item.email,department:item.department,expire_date:item.expireDate,dept_code:item.deptCode,mgr_code:item.mgrCode,title: item.title,onboard_date: item.onboardDate,regular_date: item.regularDate,password: '123123')
      #不再从tblemployee同步，直接更改密码及删除过期用户
      User.find_each do |u|
        #u = User.find_or_initialize_by(uid: item.userId)
        #u.expire_date=item.expireDate
        if u.expire_date && u.expire_date < _date
          Rails.logger.info { "-----------delete user :#{u.user_name}" }
          u.delete and next
        end
        #u.user_name = item.name
        #u.email=item.email
        #2015-12-29 部门字段已更新其意义为该用户可管理的部门，同步时不再同步
        #u.department=item.department
        #u.dept_code=item.deptCode unless u.dept_code == ''
        #2015-03-27 09:37 javy don't sys the mgrcode and department
        #u.mgr_code=item.mgrCode
        #2015-04-17 15:05 javy don't sys the title
        #u.title= item.title
        #u.onboard_date= item.onboardDate
        #u.regular_date= item.regularDate
        #u.work_date= item.workDate



        #有email的用户才会设置密码，否则使用默认密码
        if u.email
          _uname = u.email[/.*(?=@)/,0]
          unless StaticPwdUsers.include?(_uname)
            if need_change_pwd
              u.password = pwds[_uname]
              u.remember_token_expires_at = nil
              u.remember_token            = nil
            end
          end
          #只有新用户才会无密码，所以在此初始化部分数据
          #if u.password_digest.nil?
          #  u.password = '123123'
          #  u.title = item.title
          #  #初始化其year_info
          #  #u.create_last_year_info
          #end
        else
          u.password = '123123'
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

      #User.where("expire_date < current_date() ").delete_all
    end

    def self.calcute_year_info_data(tbl_user,date=Date.today)

      year_info = YearInfo.find_or_create_by(user_id: tbl_user.id,year: date.year)
      return if year_info.irregular? || tbl_user.onboard_date.nil?

      _on_board_years = date.year - tbl_user.onboard_date.year

      if _on_board_years  < 1
        return
      elsif _on_board_years == 1
         _tmp_month = date.month - tbl_user.onboard_date.month
         return if _tmp_month < 0
         return if _tmp_month == 0 && date.day <= tbl_user.onboard_date.day

      end

      #on_board_years = (date - user.onboard_date).fdiv(365) rescue(Rails.logger.debug{"#{user.id} 司龄计算错误"};0)
      #如果用户的转正日期小于等于于今日，则更新用户的基础带薪病假
      if tbl_user.regular_date && tbl_user.regular_date <= date || tbl_user.onboard_date.year <= 2014
        year_info.sick_leave = OaConfig.setting(:sick_leave_days).to_i * 10
      end

      if tbl_user.work_date
        _,_,_,_,_month,_year = tbl_user.work_date.to_time.to_a
        _total_years = date.year - _year
        _total_years -= 1 if date.month < _month
      else
        _total_years = 0
      end
      #Rails.logger.info "------------#{date}------------#{_total_years}"

      year_info.year_holiday = if _total_years < 1
                                 0
                               elsif _total_years < 10
                                 50
                               elsif _total_years < 20
                                 100
                               else
                                 150
                               end
      #if _on_board_years == 1
      if year_info.year_holiday_changed?
        _all_days = date.end_of_year.yday
        year_info.year_holiday = ((_all_days - date.yday).fdiv(_all_days) * year_info.year_holiday/5).round * 5
      end

      #binding.pry

      #Rails.logger.info "=================#{year_info.year_holiday}"
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
