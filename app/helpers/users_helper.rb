module UsersHelper
  def dis_dept(dept)
    @cache_department ||= User.cache_departments
    @cache_department.rassoc(dept).try(:[],0)
  end

  def manager_users_ary
    #3为部门管理员，3为数据库固定id,表示具有部门管理员角色的用户
    @manager_users ||= Role.find(3).users.pluck(:user_name,:uid)
  end
end
