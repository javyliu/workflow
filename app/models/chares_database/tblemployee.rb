module CharesDatabase
  class Tblemployee < ThirdTable
    self.table_name = 'tblemployee'
    self.primary_key = 'userId'

    StaticPwdUsers = %w{postmaster addressbak kjvv gamepipsender techadmin hwang yhzhao jcui cwu kjgao pippay pippay2 yiqing.chang x mzsq y yang.liu yongqing.liu yhrx}

    def self.sys_users(path="/root/sh/mailpasswd.txt")
      pwds = Hash[*YAML.load_file(path).split(/:|\s+/)]
      self.find_each do |item|
        #User.create!(uid: item.userId,user_name:item.name,email:item.email,department:item.department,expire_date:item.expireDate,dept_code:item.deptCode,mgr_code:item.mgrCode,title: item.title,onboard_date: item.onboardDate,regular_date: item.regularDate,password: '123123')
        u = User.find_or_initialize_by(uid: item.userId)
        u.user_name = item.name
        u.email=item.email
        u.department=item.department
        u.expire_date=item.expireDate
        u.dept_code=item.deptCode
        u.mgr_code=item.mgrCode
        u.title= item.title
        u.onboard_date= item.onboardDate
        u.regular_date= item.regularDate
        #有email的用户才会设置密码，否则不设
        if u.email
          _uname = u.email[/.*(?=@)/,0]
          u.password = pwds[_uname] unless StaticPwdUsers.include?(_uname)
          if u.password.nil? && u.new_record?
            u.password = '123123'
          end
        end

        #u.password = u.email? ? (pwds[u.email[/.*(?=@)/,0]] || '123123') : '123123' #如果邮箱为空,或密码表为空，则设置密码为123123
        #puts u.inspect
        u.save!
      end
    end
  end
end
