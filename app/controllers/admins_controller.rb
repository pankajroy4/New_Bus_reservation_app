class AdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin, only: [:show, :approve, :disapprove]

  def show
    @user = current_user
  end

  def approve
    @busowner = User.bus_owner.find(params[:user_id])
    @bus = Bus.find(params[:id])
    if @bus.approve!
      respond_to do |format|
        format.html { redirect_to bus_owner_bus_path(@busowner, @bus), notice: "Bus approved successfully!." }
        format.turbo_stream { flash.now[:notice] = "Bus Approved successfully!." }
      end
    end
  end

  def disapprove
    @busowner = User.find_by(id: params[:user_id])
    @bus = Bus.find(params[:id])
    if @bus.disapprove!
      respond_to do |format|
        format.html { redirect_to bus_owner_bus_path(@busowner, @bus), notice: "Bus Disapproved successfully!." }
        format.turbo_stream { flash.now[:alert] = "Bus Dispproved successfully!." }
      end
    end
  end

  private

  def authorize_admin
    @admin = current_user
    authorize @admin, policy_class: AdminPolicy
  end

  def authenticate_admin!
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Requires login/signup!"
    end
  end
end
