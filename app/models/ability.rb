class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.role_group.nil?
      cannot :manage, :all
      can :read,Checkinout,user_id: user.id
    elsif user.role?("admin")
      can :manage, :all
      #can :read,Checkinout,user_id: user.leader_data.try(:last)
    elsif user.role?("manager")
      can :read,Checkinout,user_id: user.leader_data.try(:last)
      can :search,Checkinout
      can :read,:all
    elsif user.role?("department_manager")
      cannot :manage, :all
      can :read,Checkinout,user_id: user.leader_data.try(:last)
      can :search,Checkinout
      can :manage,Journal do |journal|
        user.leader_data.try(:include?,journal.user_id)
      end
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
