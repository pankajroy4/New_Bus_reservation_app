class BusOwnersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]

  def index
    @bus_owners = User.bus_owner
    authorize current_user, policy_class: BusOwnerPolicy
  end

  def show
    @bus_owner = User.bus_owner.find(params[:id])
    authorize @bus_owner, policy_class: BusOwnerPolicy
  end
end
