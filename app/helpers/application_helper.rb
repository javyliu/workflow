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
end
