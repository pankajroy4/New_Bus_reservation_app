class Users::SessionsController < Devise::SessionsController
  def new
    super
  end

  def otp_verification
    sign_out(current_user) if current_user
    @email = params[:email]
    @user = User.find_by(email: @email)
    @remember_me = params[:remember_me]
    if (@user&.valid_password?(params[:password]) && @user&.confirmed?)
      @user.generate_and_send_otp
      flash.now[:notice] = "A new OTP has been sent to your email."
      respond_to do |format|
        format.html { render :otp_verification }
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("otp", partial: "users/sessions/otp_verification", locals: { email: @email, remember_me: @remember_me })
        }
      end
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

  def resend_otp
    @email = params[:email]
    @remember_me = params[:remember_me]
    user = User.find_by(email: @email)
    if user
      user.generate_and_send_otp
      flash.now[:notice] = "OTP resended, check your mail!"
      respond_to do |format|
        format.html { render :otp_verification, status: :ok }
        format.turbo_stream { flash.now[:notice] = "OTP resended, check your mail please!." }
      end
    else
      redirect_to root_path, alert: "Invalid email address."
    end
  end

  def create
    @email = params[:email]
    user = User.find_by(email: @email)
    @remember_me = params[:remember_me]
    if user && user.valid_otp?(params[:otp])
      user.update!(remember_me: @remember_me)
      sign_in(:user, user)
      if user.admin?
        redirect_to admin_show_path(user.id), notice: "Admin logged in successfully!"
      else
        redirect_to user_path(user.id), notice: "Logged in successfully!"
      end
    else
      flash.now[:alert] = "Invalid email or OTP."
      respond_to do |format|
        format.html { render :otp_verification, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("otp", partial: "users/sessions/otp_verification", locals: { email: @email, remember_me: @remember_me })
        }
      end
    end
  end

  def after_sign_in_path_for(resource)
    user_path(resource)
  end

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp])
  end
end

# =======================================================================

# def otp_verification
#   sign_out(current_user) if current_user
#   @email = params[:email]
#   @user = User.find_by(email: @email)
#   @remember_me = params[:remember_me]
#   if ( (@user && @user.valid_password?(params[:password]) ) && @user&.confirmed?)
#     @user.generate_and_send_otp
#     flash.now[:notice] = 'A new OTP has been sent to your email.'
#   else
#     if @user
#       if @user.confirmed?
#         flash.now[:alert] = 'Invalid  password!'
#       else
#         flash.now[:alert] = 'You have to confirm your email first!'
#       end
#     else
#       flash.now[:alert] = 'Invalid email or password!'
#     end
#     render :new, status: :unprocessable_entity
#   end
# end
