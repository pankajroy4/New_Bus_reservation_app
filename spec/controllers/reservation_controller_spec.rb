require "rails_helper"

RSpec.describe ReservationsController, type: :controller do
  let(:user) { create(:user) }
  let(:busowner) { create(:bus_owner) }
  let(:bus) { create(:bus, bus_owner: busowner, approved: true) }
  let(:seat) { create(:seat, bus: bus) }
  let(:reservation) { create(:reservation, bus: bus, user: user, seat: bus.seats.first, date: Date.today) }

  before do
    sign_in(user)
  end

  describe "GET #new" do
    it "assigns necessary variables and renders the 'new' template" do
      get :new, params: { bus_id: bus.id }
      expect(assigns(:user)).to eq(user)
      expect(assigns(:bus)).to eq(bus)
      expect(assigns(:reservation)).to be_a_new(Reservation)
      expect(response).to render_template("new")
    end
  end

  describe "POST #create" do
    context "with valid parameters as turbo stream" do
      it "creates a new reservation and redirects to bookings_path" do
        valid_params = { reservation: { user_id: user.id, bus_id: bus.id, seat_id: [bus.seats.first.id], date: Date.today }, bus_id: bus.id }
        expect { post :create, params: valid_params, format: :turbo_stream }.to change(Reservation, :count).by(1)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(bookings_path(user))
        expect(flash[:notice]).to eq("Booking successful!")
      end
    end

    context "with valid parameters as HTML" do
      it "creates a new reservation and redirects to bookings_path" do
        valid_params = { reservation: { user_id: user.id, bus_id: bus.id, seat_id: [bus.seats.first.id], date: Date.today }, bus_id: bus.id }
        expect { post :create, params: valid_params }.to change(Reservation, :count).by(1)
        expect(response).to redirect_to(bookings_path(user))
        expect(flash[:notice]).to eq("Booking successful!")
      end
    end

    context "with invalid parameters as turbo_stream" do
      it "renders the 'new' template and shows an alert" do
        post :create, params: { reservation: { user_id: user.id, bus_id: bus.id, seat_id: [], date: Date.today }, bus_id: bus.id }, format: :turbo_stream
        expect(flash[:alert]).to eq("Select Date & Seats first!")
      end
    end

    context "with invalid parameters as HTML" do
      it "renders the 'new' template and shows an alert" do
        post :create, params: { reservation: { user_id: user.id, bus_id: bus.id, seat_id: [], date: Date.today }, bus_id: bus.id }
        expect(response).to render_template("new")
        expect(flash[:alert]).to eq("Select Date & Seats!")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the reservation and redirects to bookings_path" do
      delete :destroy, params: { id: reservation.id, bus_id: bus.id }
      is_expected.to redirect_to(bookings_path(user))
      expect(flash[:alert]).to eq("Ticket cancelled!.")
    end

    it "reservation not found" do
      delete :destroy, params: { id: reservation.id, bus_id: bus.id }
      delete :destroy, params: { id: reservation.id, bus_id: bus.id }
      expect(assigns(:reservation)).to be_nil
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET #booking" do
    it "assigns user and bookings and renders the 'booking' template" do
      get :booking, params: { user_id: user.id }
      expect(assigns(:user)).to eq(user.id.to_s)
      expect(assigns(:bookings)).to eq([reservation])
      expect(response).to render_template("booking")
    end
  end
end
