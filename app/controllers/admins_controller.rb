class AdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin, only: [:show, :approve, :disapprove]

  def show
    @user = current_user
    respond_to do |format|
      format.json { render json: @user.as_json(except: [:otp, :otp_sent_at]) }
      format.html { render :show }
    end
  end

  def approve
    # @busowner = User.bus_owner.find(params[:user_id])
    @bus = Bus.find(params[:id])
    @busowner = @bus.user

    if @bus.approve!
      respond_to do |format|
        format.html { redirect_to bus_owner_bus_path(@busowner, @bus), notice: "Bus approved successfully!." }
        format.turbo_stream { flash.now[:notice] = I18n.t('controllers.admins.message.bus_approval_message') }
        format.json { render json: { bus_owner: @bus_owner.as_json(except: [:otp, :otp_sent_at]), bus: @bus }, status: :created }
      end
    end
  end

  def disapprove
    @busowner = User.find_by(id: params[:user_id])
    @bus = Bus.find(params[:id])
    if @bus.disapprove!
      respond_to do |format|
        format.html { redirect_to bus_owner_bus_path(@busowner, @bus), notice: "Bus Disapproved successfully!." }
        format.turbo_stream { flash.now[:alert] = I18n.t('controllers.admins.message.bus_disapproval_message') }
        format.json { render json: { bus_owner: @bus_owner.as_json(except: [:otp, :otp_sent_at]), bus: @bus }, status: :created }
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
