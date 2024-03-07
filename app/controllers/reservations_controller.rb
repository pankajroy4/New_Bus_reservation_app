class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_approved, except: [:booking]

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
    @success = Reservation.create_reservations(user_id, bus_id, seat_ids, parsed_date)
    respond_to do |format|
      if !@success.is_a?(Array)
        format.html { redirect_to bookings_path(user_id), notice: "Booking successful!" }
        format.turbo_stream { redirect_to bookings_path(user_id), notice: "Booking successful!" }
        format.json { render json: { bookings: current_user.reservations, message: "Booking successfull!" } }
      else
        # binding.pry
        flash[:alert] = @success[0][0]
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { flash.now[:alert] = @success[0][0] }
        format.json { render json: { errors: "Select Date & Seats first!" }, status: :unprocessable_entity }
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

  private

  def require_approved
    @bus = Bus.find(params[:bus_id])
    unless @bus.approved
      redirect_to root_path, alert: "Bus not approved yet!"
    end
  end
end