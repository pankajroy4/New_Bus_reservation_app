class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_approved, except: [:booking, :download_pdf]

  def new
    @user = current_user
    @reservation = Reservation.new
    @date = params[:date] || Date.today
    @available_seats = @bus.seats.all
    @booked_seats = Reservation.display_searched_date_seats(@bus, @date)
  end

  def create
    param = params[:reservation]
    bus_id = param[:bus_id]
    user_id = param[:user_id]
    seat_ids = param[:seat_ids]
    date = param[:date]
    parsed_date = Date.parse(date)
    res = Reservation.create_reservations(user_id, bus_id, seat_ids, parsed_date) if !seat_ids.blank?
    respond_to do |format|
      if !res
        flash[:alert] = "Select Date & Seats first!"
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { flash.now[:alert] = "Select Date & Seats first!" }
        format.json { render json: { errors: "Select Date & Seats first!" }, status: :unprocessable_entity }
      else
        if (res[:success])
          format.html { redirect_to bookings_path(user_id), notice: "Booking successful!" }
          format.turbo_stream { redirect_to bookings_path(user_id), notice: "Booking successful!" }
          format.json { render json: { bookings: current_user.reservations, message: "Booking successfull!" } }
        else
        flash[:alert] = res[:errors][0]
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { flash.now[:alert] = res[:errors][0] }
        format.json { render json: { errors: res[:errors][0] }, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @reservation = Reservation.find_by(id: params[:id])
    @user = @reservation&.user
    authorize @user, policy_class: ReservationPolicy
    if @reservation.destroy
      respond_to do |format|
        format.html { redirect_to bookings_path(current_user.id), alert: "Ticket cancelled!." }
        format.turbo_stream { flash.now[:alert] = "Ticket Cancelled!." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to bookings_path(current_user.id), status: :unprocessable_entity, notice: "Ticket cancellation failed." }
        format.json { render json: { message: "Ticket cancellation failed" }, status: :unprocessable_entity }
      end
    end
  end

  def booking
    @user = params[:user_id]
    @bookings = policy_scope(Reservation)
    respond_to do |format|
      format.html { render :booking }
      format.json { render json: { bookings: @bookings, user: current_user.as_json(except: [:otp, :otp_sent_at]) } }
    end
  end

  def download_pdf
    subpath = "download_pdf"
    reservations = current_user.reservations

    data = WickedPdf.new.pdf_from_string(
      ApplicationController.new.render_to_string(
        "reservations/#{subpath}",
        layout: "layouts/pdf_bg", locals: { user: current_user, reservations: reservations },
      ),
      header: { right: "page [page] of [topage]", left: Time.zone.now.strftime("%e %b, %Y") },
      footer: { right: "abcgd", left: "dfsdfdf" },
    )
    file_name = "ticket-#{Time.zone.now.to_i}-#{current_user.id}"

    # send_data data, filename: "ticket.pdf", type: "application/pdf", disposition: "attachment"
    #NOTE : For direct download , above line is sufficient. All below code  sholud be removed in case you want to apply direct download without db storage.

    save_path = Tempfile.new("your_bookings-#{Time.zone.now.to_i}-#{current_user.id}.pdf")
    File.open(save_path, "wb") do |file|
      file << data
    end

    current_user.ticket_pdf.purge if current_user.ticket_pdf.present?
    current_user.ticket_pdf.attach(io: File.open(save_path.path), filename: "#{file_name}.pdf", content_type: "pdf")
    save_path.unlink
    redirect_to rails_blob_url(current_user.ticket_pdf, disposition: "attachment")
  end

  private

  def require_approved
    @bus = Bus.find(params[:bus_id])
    unless @bus.approved
      redirect_to root_path, alert: "Bus not approved yet!"
    end
  end
end
