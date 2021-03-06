class Resource
  include RoleMaking::Resourcing

  group :kaoqing do
    resource [:update,:create],Approve
    resource :list,Checkinout,res_name: 'department_checkinout',con: {user_id: 'user.leader_data.try(:[],"user_ids")'}

    resource [:list,:export,:create,:update],Journal,res_name: 'department_journal',con: {user_id: 'user.leader_data.try(:[],"user_ids")'}

    resource [:list,:destroy,:export],Episode,res_name: 'department_episode',con: {user_id: 'user.leader_data.try(:[],"user_ids")'}
    resource :approve,Episode,res_name: 'department_episode' do |user,episode|
      if episode.holiday_id == 19
        episode.user.director_leader == user && [0,3].include?(episode.state)
      else
        [0,3].include?(episode.state) && user.leader_data.try(:[],"user_ids").try(:include?,episode.user_id.to_s)
      end

    end

    resource [:approve],Assault,res_name: 'department_assault' do |user,assault|
      [0,3].include?(assault.state) && assault.user.vice_leader == user
    end

    resource :confirm,User,res_name: 'department_kaoqing'
    resource :kaoqing,User,res_name: 'department_kaoqing'
  end


  group :manager do
    resource [:read,:update,:destroy],Department
    #没有该action，仅用于产生不同下属部门的权限判断
    resource [:view,:change],Department,res_name: 'undering_dept'

    resource [:read,:update,:destroy,:export,:list],Episode
    resource :list,Checkinout
    resource :create,Checkinout, res_name: 'user_checkinout',action_scope: 'other_actions'
    #modify 用于页面是否显示修改链接
    resource [:modify,:create,:update,:list,:export],Journal
    resource :manage,Holiday
    resource [:read,:update,:create,:destroy,:export],User
    resource [:read,:update],User, res_name: 'department_user',con: {uid: 'user.leader_data.try(:[],"user_ids")'}
    resource :display,User,res_name: 'menu'
    resource :manage,SpecDay
    resource [:read,:update],OaConfig
    resource [:read,:update],AttendRule
    resource [:read,:update],ReportTitle
    resource [:read,:update,:create,:export],YearInfo
    resource :manage,Role
    resource [:read,:create,:update,:destroy],Assault
    resource :manage,EmSerCate
    resource :manage,EmService
  end

  group :change_pwd do
    #用户更改密码
    resource [:manual_unify_delete,:unify_delete,:unify_reset],User,res_name: 'pwd_user'
  end

  #用于在角色管理界面列出查看部门资源
  #业务上用于某角色可查看的部门数组
  #group :user do
  #  resource [:read,:update,:destroy], User do |admin,user|
  #    admin != user
  #  end

  #  resource :create,User

  #end

  #group :post do
  #  resource :read,Post
  #  resource [:update,:destroy,:create],Post
  #end

  ##with hashs
  #group :post do
  #  resource :read,Post
  #  resource [:update,:destroy,:create],Post,con: {user_id: 'user.leader_data'}
  #end
end
