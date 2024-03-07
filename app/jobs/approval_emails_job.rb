
class ApprovalEmailsJob < ApplicationJob
  queue_as :default

  def perform(bus)
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      domain: "gemsessence.com",
      user_name: Rails.application.credentials.smtp_username,
      password: Rails.application.credentials.smtp_password,
      authentication: "plain",
      enable_starttls_auto: true,
      open_timeout: 5,
      read_timeout: 5,
    }
    BusApprovalMailer.approval_email(bus).deliver
  end
end