class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def create 
    if params[:user][:role].in?(["user", "bus_owner"])
      super
    else
      build_resource(sign_up_params)
      flash[:alert] = "Invalid role"
      render :new, status: :unprocessable_entity
    end
  end

  def after_sign_up_path_for(resource)
    user_path(resource)
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role, :registration_no])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :registration_no])
  end
end
