class UserMailer < Devise::Mailer
  def custom_confirmation_instructions(record, token, otp)
    @resource = record
    @token = token
    @otp = otp
    devise_mail(record, :confirmation_instructions, otp)
  end
end
