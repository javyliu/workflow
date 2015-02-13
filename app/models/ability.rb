class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    cannot :manage, :all
    can :read,[Checkinout,Episode],user_id: user.id
    can [:home],User,uid: user.id
    can [:create,:update],Episode,user_id: user.id

    if user.role?("admin")
      can [:destroy,:list],:all
      can [:kaoqing,:confirm],User
      #can :read,Checkinout,user_id: user.leader_data.try(:last)
    elsif user.role?("department_manager")
      can :list,Checkinout,user_id: user.leader_data.try(:last)
      can :search,Checkinout
      can [:kaoqing,:confirm],User
      can :list,Journal do |journal|
        user.leader_data.try(:include?,journal.user_id)
      end
    elsif user.role?("manager")
      can :list,[Checkinout,Episode]#,user_id: user.leader_data.try(:last)
      can :search,Checkinout
    elsif user.role_group.nil?
      can [:index,:home],User,uid: user.id
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
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
