class BusOwnerPolicy < ApplicationPolicy
  def show?
    user.admin? || (user.bus_owner? && user == record)
  end

  def index?
    user.admin?
  end
end
