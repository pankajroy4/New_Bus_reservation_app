class BusPolicy < ApplicationPolicy
  class Scope < Scope
  end

  def update?
    user.bus_owner? && (user == record)
  end

  def view?
    user&.bus_owner? && (user.id == record.user_id)
  end

  def edit?
    update?
  end

  def destroy?
    user.bus_owner? && user == record
  end

  def reservations_list?
    user.bus_owner? && record.approved? && (record.user_id == user.id)
  end

  def index?
    # (user.admin? || user.bus_owner?)
    user.admin? || (user.bus_owner? && record == user)
  end

  def new?
    user.bus_owner? && record.bus_owner?
  end
end
