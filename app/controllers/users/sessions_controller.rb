class Users::SessionsController < Devise::SessionsController

  def resend_otp
    @email = params[:email]
    @remember_me = params[:remember_me]
    user = User.find_by(email: @email)
    if user
      user.generate_and_send_otp
      flash.now[:notice] = "OTP resended, check your mail!"
      render turbo_stream: turbo_stream.update("otp", partial: "users/sessions/otp_verification", locals: { email: @email, remember_me: @remember_me }) #will no longer needed after handling onclick
    else
      redirect_to root_path, alert: "Invalid email address."
    end
  end

  def create
    @email = params[:email]
    user = User.find_by(email: @email)
    @remember_me = params[:remember_me]

    if (params[:otp_step])
      if user && user.valid_otp?(params[:otp])
        user.update!(remember_me: @remember_me)
        sign_in(:user, user)
        if user.admin?
          redirect_to admin_show_path(user.id), notice: "Admin logged in successfully!"
        else
          redirect_to after_sign_in_path_for(user), notice: "Logged in successfully!"
        end
      else
        flash.now[:alert] = "Invalid email or OTP."
        render turbo_stream: turbo_stream.update("otp", partial: "users/sessions/otp_verification", locals: { email: @email, remember_me: @remember_me })
      end
    else
      sign_out(current_user) if current_user
      @email = params[:email]
      @user = User.find_by(email: @email)
      @remember_me = params[:remember_me]
      if (@user&.valid_password?(params[:password]) && @user&.confirmed?)
        @user.generate_and_send_otp
        flash.now[:notice] = "A new OTP has been sent to your email."
        render turbo_stream: turbo_stream.update("otp", partial: "users/sessions/otp_verification", locals: { email: @email, remember_me: @remember_me })
      else
        if @user
          if @user.confirmed?
            flash.now[:alert] = "Invalid  password!"
          else
            flash.now[:alert] = "You have to confirm your email first!"
          end
        else
          flash.now[:alert] = "Invalid email or password!"
        end
        render :new, status: :unprocessable_entity
      end
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || user_path(resource_or_scope)
  end

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp, :otp_step, :profile_pic])
  end
end
