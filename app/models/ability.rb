class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new
    can :show, User, id: user.id
    can :manage, Calendar
    can :manage, Event, user_id: user.id
  end
end
