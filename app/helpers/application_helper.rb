module ApplicationHelper
  def cur_page?(*args)
    _con_name,*_action = args
    _con_name = controller_name if _con_name.blank?
    if _action.blank? && _con_name == controller_name
      return true
    elsif _action.include?(action_name) && _con_name == controller_name
      return true
    end
  end

  #当前用户可管理的部门列表,用于select
  def cache_dept
    @cache_dept ||= if current_user.has_role?(:admin)
                      User.cache_departments
                    else
                      role_depts = current_user.role_depts(current_ability)
                      User.cache_departments.find_all{|item| role_depts.include?(item[1])}
                    end.group_by{|it| it[2]}.transform_values!{|it| it.each{|item| item.slice!(2)} }

  end
end
