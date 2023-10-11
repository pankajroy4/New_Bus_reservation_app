class BusApprovalMailer < ApplicationMailer
  def approval_email(bus)
    @bus = bus
    mail to: @bus.bus_owner.email, subject: "Bus approval Email!!"
  end
end
