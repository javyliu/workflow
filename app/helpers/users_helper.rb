module UsersHelper
  def dis_dept(dept)
    @cache_department ||= User.cache_departments
    @cache_department.rassoc(dept).try(:[],0)
  end
end
