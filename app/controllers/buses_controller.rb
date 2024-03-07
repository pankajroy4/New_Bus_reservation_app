class BusesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy, :index]
  before_action :authorize_user, only: [:edit, :update, :destroy, :index, :new]

  def reservations_list
    @date = params[:date]
    @bus = Bus.find(params[:bus_id])
    @reservations = @bus.reservations.where(date: @date)
    authorize @bus
    respond_to do |format|
      format.html { render :reservations_list }
      # format.json { render json: { bus: @bus, reservations: @reservations } }
      format.json do
        json_response = {
          date: @date,
          bus: @bus,
          reservations: @reservations.map do |reservation|
            {
              id: reservation.id,
              seat_number: reservation.seat.seat_no,
              seat_id: reservation.seat_id,
              passenger: {
                passenger_id: reservation.user.id,
                passenger_name: reservation.user.name,
              },
            }
          end,
        }
        render json: json_response
      end
    end
    #http://localhost:3000/get_resv_list/1.json?date=12-10-2023
  end

  def new
    @busowner = User.find(params[:bus_owner_id])
    @bus = @busowner.buses.new
  end

  def show
    @busowner = User.find(params[:bus_owner_id])
    @bus = @busowner.buses.find(params[:id])
    # @available_seats = @bus.seats
    respond_to do |format|
      format.html { render :show }
      format.json { render json: { bus: @bus, bus_owner: @busowner } }
    end
    # http://localhost:3000/bus_owners/2/buses/1.json
  end

  def create
    @busowner = User.find(params[:bus_owner_id])
    @bus = @busowner.buses.new(bus_params)
    if @bus.save
      respond_to do |format|
        format.html { redirect_to user_path(@busowner), notice: "Bus added successfully!" }
        format.json { render json: { bus: @bus, bus_owner: @busowner }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @bus.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def index
    @buses = @busowner.buses.all
    respond_to do |format|
      format.json { render json: { bus: @buses, owner: @busowner } }
      format.html { render :index }
    end
    # http://localhost:3000/bus_owners/2/buses.json
  end

  def edit
    @bus = @busowner.buses.find(params[:id])
  end

  def update
    @bus = @busowner.buses.find(params[:id])
    if @bus.update(bus_params)
      respond_to do |format|
        format.html { redirect_to bus_owner_bus_path(@busowner, @bus), notice: "Bus info. updated successfully!" }
        format.json { render json: { bus: @bus, bus_owner: @busowner, message: "Bus info. updated successfully!" } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @bus.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bus = @busowner.buses.find(params[:id])
    if @bus.destroy
      respond_to do |format|
        format.html { redirect_to bus_owner_buses_path(@busowner), status: :see_other, notice: "Bus removed successfully!" }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to bus_owner_buses_path(@busowner), status: :unprocessable_entity, notice: "Bus removal failed." }
        format.json { render json: { message: "Bus removal failed." }, status: :unprocessable_entity }
      end
    end
  end

  private

  def bus_params
    params.require(:bus).permit(:name, :registration_no, :route, :total_seat, :approved, :main_image)
  end

  def authorize_user
    @busowner = User.find_by(id: params[:bus_owner_id])
    authorize @busowner, policy_class: BusPolicy
  end
end
