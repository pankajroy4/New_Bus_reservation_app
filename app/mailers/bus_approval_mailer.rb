class BusApprovalMailer < ApplicationMailer
  def approval_email(bus)
    @bus = bus
    attachments.inline["image.jpg"] = @bus.main_image.download
    mail to: @bus.user.email, subject: "Bus approval Email!!" if bus.user.bus_owner?
  end
end
