class OtpVerificationMailer < ApplicationMailer
  def otp_verification_mailer(record, otp)
    @user = record
    @otp = otp
    mail(to: @user.email, subject: "Your OTP for Login")
  end
end
