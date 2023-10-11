class UserPolicy < ApplicationPolicy
  class Scope < Scope
  end

  def show?
    record.present? && (user.admin? || (user == record))
  end
  
  def update?
    user == record
  end

  def index?
    user.admin?
  end
end
