class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    #cannot :manage, :all
    can :read,[Checkinout,Episode],user_id: user.id
    can :destroy,[Episode] do |episode|
      episode.user_id == user.id && episode.state.to_i == 0
    end
    #can [:index,:home],User,uid: user.id
    can [:update,:change_pwd,:home],User,uid: user.id
    cannot :edit,User
    can [:index],Journal,user_id: user.id
    can [:create],Episode,user_id: user.id
    can [:update],Episode do |episode|
      episode.user_id == user.id && episode.state.to_i == 0
    end

    #2015-06-03 11:18 所有用户都可以更改考勤系统密码，除固定密码用户外，密码会被定期修改
    #can [:change_pwd,:update,:show]#,User if user.email_en_name.in?(CharesDatabase::Tblemployee::StaticPwdUsers)

    #if user.role?("kaoqin_viewer")
    #  can [:list],[Checkinout,Episode,Journal]
    #  can :show,Episode
    #  can :list,Department
    #  can :export,[Journal,Episode]
    #  #can [:kaoqing],User
    #  #can :list,Journal do |journal|
    #  #  user.leader_data.try(:include?,journal.user_id)
    #  #end
    #end

    #if user.role?("manager")
    #  can :manage,[SpecDay,OaConfig,AttendRule,ReportTitle,YearInfo,Department]
    #  can [:read,:create,:edit,:update,:change_pwd],User
    #  can :list,[Checkinout,Episode,Journal]#,user_id: user.leader_data.try(:last)
    #  can :export,:all
    #  can :show,Episode
    #  #cannot :change_pwd,User unless user.email_en_name.in?(CharesDatabase::Tblemployee::StaticPwdUsers)
    #  #用于显示管理功能菜单
    #  can :display,User
    #  can :create,:all
    #  can :update,Journal
    #  cannot [:kaoqing,:confirm],:all
    #  cannot :create,Approve

    #end
    ##密码管理员
    #if user.role?("pwd_manager")
    #  can [:read,:update,:change_pwd,:unify_reset,:unify_delete,:manual_unify_delete],User
    #  can :display,User
    #  #cannot :edit,User
    #end

    #if user.role?("department_manager")
    #  can [:list],[Checkinout,Episode,Journal],user_id: user.leader_data.try(:last)
    #  can :destroy,Episode,user_id: user.leader_data.try(:last)
    #  can :show,Episode
    #  can :confirm,:all
    #  can :create,Approve
    #  can :create,Journal, user_id: user.leader_data.try(:last)
    #  can :export,[Journal,Episode],user_id:  user.leader_data.try(:last)
    #  can :update,Journal
    #  can [:kaoqing,:confirm],User
    #  #can :list,Journal do |journal|
    #  #  user.leader_data.try(:include?,journal.user_id)
    #  #end
    #end



    #if user.role?("admin")
    #  can :manage,[SpecDay,OaConfig,AttendRule,User,ReportTitle,YearInfo,Department]
    #  #cannot :change_pwd,User unless user.email_en_name.in?(CharesDatabase::Tblemployee::StaticPwdUsers)
    #  can :export,:all
    #  can :create,:all
    #  can :confirm,:all
    #  can [:destroy,:list],:all
    #  can :update,Journal
    #  #can :read,Checkinout,user_id: user.leader_data.try(:last)
    #end

    #if user.role?("badman")
    #  cannot manage,:all
    #end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #Role.all_without_reserved.each do |role|
    #  next unless user.has_role?(role.name)
    user.roles.each do |role|
      next if role.name == "admin"
      role.role_resources.each do |res|
        resource = Resource.find_by_name(res.resource_name) rescue next
        if block = resource.behavior
          can resource.verb,resource.object do |obj|
            block.call(user,obj)
          end
        elsif resource.hashs
          eval_con = resource.hashs[:con].try(:inject,{}) do |r,(k,v)|
            r[k] = eval(v)
            r
          end || {}
          can resource[:verb],resource[:object],resource[:hashs].except(:con).merge(eval_con)
        else
          can resource[:verb],resource[:object]
        end
      end
    end

    if user.has_role?(:admin)
      can :manage,:all
    end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
  protected
  def basic_read_only
    can :read,    :all
    can :create,  :all
  end
end
