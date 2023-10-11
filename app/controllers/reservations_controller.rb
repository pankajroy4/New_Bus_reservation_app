class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_approved, except: [:booking]

  def new
    @user = current_user
    @reservation = Reservation.new
    @date = params[:date] || Date.today
    @available_seats = Reservation.display_searched_date_seats(@bus, @date)
  end

  def create
    param = params[:reservation]
    bus_id = param[:bus_id]
    user_id = param[:user_id]
    seat_ids = param[:seat_id]
    date = param[:date]
    parsed_date = Date.parse(date)
    @success = Reservation.create_reservations(user_id, bus_id, seat_ids, parsed_date)
    respond_to do |format|
      if @success
        format.html { redirect_to bookings_path(user_id), notice: "Booking successful!" }
        format.turbo_stream { redirect_to bookings_path(user_id), notice: "Booking successful!" }
      else
        flash[:alert] = "Select Date & Seats!"
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { flash.now[:alert] = "Select Date & Seats first!" }
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
      end
    end
  end

  def booking
    @user = params[:user_id]
    @bookings = policy_scope(Reservation)
  end

  private

  def require_approved
    @bus = Bus.find(params[:bus_id])
    unless @bus.approved
      redirect_to root_path, alert: "Bus not approved yet!"
    end
  end
end
