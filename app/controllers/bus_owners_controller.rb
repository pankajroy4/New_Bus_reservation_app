class BusOwnersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]

  def index
    @bus_owners = User.bus_owner
    authorize current_user, policy_class: BusOwnerPolicy
    respond_to do |format|
      format.json { render json: @bus_owners.as_json(except: [:otp, :otp_sent_at]) }
      format.html { render :index }
    end
    # http://localhost:3000/bus_owners.json
  end

  def show
    @bus_owner = User.bus_owner.find(params[:id])
    authorize @bus_owner, policy_class: BusOwnerPolicy
    respond_to do |format|
      format.json { render json: @bus_owner.as_json(except: [:otp, :otp_sent_at]) }
      format.html { render :show }
    end
    # http://localhost:3000/bus_owners/2.json
  end
end
