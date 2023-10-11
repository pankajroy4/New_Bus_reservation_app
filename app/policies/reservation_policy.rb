class ReservationPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end
  
  def destroy?
    user.id == record&.id
  end
end
