class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
    authorize User
    respond_to do |format|
      format.json { render json: @users.as_json(except: [:otp, :otp_sent_at]) }
      format.html { render :index }
    end
  end

  def show
    @user = User.includes(profile_pic_attachment: :blob).find(params[:id])
    authorize @user
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @user.as_json(except: [:otp, :otp_sent_at]) }
    end
  end
end
