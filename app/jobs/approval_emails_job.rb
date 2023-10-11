
class ApprovalEmailsJob < ApplicationJob
  queue_as :default

  def perform(bus)
    BusApprovalMailer.approval_email(bus).deliver
  end
end