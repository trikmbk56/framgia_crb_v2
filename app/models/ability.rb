class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new
    can :show, User, id: user.id
    can :manage, Calendar
    can :manage, Event
    can :manage, Attendee
    can :show, Event
  end
end
