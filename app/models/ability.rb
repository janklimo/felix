class Ability
  include CanCan::Ability

  def initialize(admin, session)
    admin ||= Admin.new
    can :manage, Company, admin_id: admin.id
  end
end
