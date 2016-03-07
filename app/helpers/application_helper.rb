module ApplicationHelper
  def cur_page?(*args)
    _con_name,*_action = args
    _con_name = Array.wrap(controller_name) if _con_name.blank?
    if _action.blank? && _con_name.include?(controller_name)
      return true
    elsif _action.include?(action_name) && _con_name.include?(controller_name)
      return true
    end
  end

  #当前用户可管理的部门列表,用于select,应该包括直属部门
  def cache_dept(user=current_user)
    @cache_dept ||= if user.has_role?(:admin)
                      User.cache_departments
                    else
                      _role_depts = user.role_depts(include_mine: true)
                      User.cache_departments.find_all{|item| _role_depts.include?(item[1])}
                    end.group_by{|it| it[2]}.transform_values{|it| it.map{|item| item[0,2]} }

  end
end
