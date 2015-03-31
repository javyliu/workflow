module CharesDatabase
  #2015-03-26 17:54 javy 在正式库中添加两个表
  class Tblemployee < ActiveRecord::Base
    self.table_name = 'tblemployee'
    self.primary_key = 'userId'

    StaticPwdUsers = %w{postmaster addressbak kjvv gamepipsender techadmin hwang yhzhao jcui cwu kjgao pippay pippay2 yiqing.chang x mzsq y yang.liu yongqing.liu yhrx}

    def self.sys_users(need_change_pwd=true,path="/root/sh/mailpasswd.txt")
      pwds = Hash[*YAML.load_file(path).split(/:|\s+/)]
      self.find_each do |item|
        #User.create!(uid: item.userId,user_name:item.name,email:item.email,department:item.department,expire_date:item.expireDate,dept_code:item.deptCode,mgr_code:item.mgrCode,title: item.title,onboard_date: item.onboardDate,regular_date: item.regularDate,password: '123123')
        u = User.find_or_initialize_by(uid: item.userId)
        u.user_name = item.name
        u.email=item.email
        u.department=item.department
        u.expire_date=item.expireDate
        u.dept_code=item.deptCode
        #2015-03-27 09:37 javy don't sys the mgrcode and department
        #u.mgr_code=item.mgrCode
        u.title= item.title
        u.onboard_date= item.onboardDate
        u.regular_date= item.regularDate
        #有email的用户才会设置密码，否则不设
        if u.email
          _uname = u.email[/.*(?=@)/,0]
          unless StaticPwdUsers.include?(_uname)
            if u.new_record? || need_change_pwd
              u.password = pwds[_uname]
            end
          end
          if u.password_digest.nil?
            u.password = '123123'
          end
        end

        #u.password = u.email? ? (pwds[u.email[/.*(?=@)/,0]] || '123123') : '123123' #如果邮箱为空,或密码表为空，则设置密码为123123
        #puts u.inspect
        u.save!
      end
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
