class CanCan::ModelAdapters::DefaultAdapter
  #打开类：cancan默认适配器，用于 current_ability.model_adapter(Menu,:display).conditions来返回设置条件
  #主要用于在resource中设置用户显示非active_record对像所对应的权限
  def conditions
    #binding.pry
    Array.wrap(@rules).inject([]){|r,it| r.push(it.conditions)}
  end
end
