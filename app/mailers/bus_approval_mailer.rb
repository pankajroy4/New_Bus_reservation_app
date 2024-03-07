class BusApprovalMailer < ApplicationMailer
  def approval_email(bus)
    @bus = bus
      mail to: @bus.user.email, subject: "Bus approval Email!!" if bus.user.bus_owner?
  end
end
