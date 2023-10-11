require "rails_helper"

RSpec.describe BusesController, type: :controller do
  let(:busowner) { create(:bus_owner) }
  let(:user) { create(:admin) }
  let(:bus) { create(:bus, bus_owner: busowner, approved: true) }
  let(:date) { Date.today }

  before do
    sign_in(busowner, scope: :bus_owner)
  end

  describe "GET #reservations_list" do
    before do
      get :reservations_list, params: { bus_id: bus.id, date: date }
    end
    it { is_expected.to render_template("reservations_list") }
    it { is_expected.to route(:get, "/get_resv_list/1").to(action: :reservations_list, bus_id: 1) }
    it { expect(assigns(:reservations)).to match_array(nil) }
    it { is_expected.to respond_with 200 }
  end

  describe "GET #new" do
    before do
      get :new, params: { bus_owner_id: busowner.id }
    end
    it { is_expected.to render_template("new") }
    it { is_expected.to route(:get, "/buses/new").to(action: :new) }
    it { is_expected.to respond_with 200 }
  end

  describe "GET #show" do
    before do
      get :show, params: { bus_owner_id: busowner.id, id: bus.id }
    end
    it { is_expected.to render_template("show") }
    it { is_expected.to route(:get, "/buses/1").to(action: :show, id: 1) }
    it { is_expected.to respond_with 200 }
  end

  describe "GET #index" do
    context "as bus owner" do
      before do
        get :index, params: { bus_owner_id: busowner.id }
      end
      it { is_expected.to render_template("index") }
      it { is_expected.to route(:get, "/buses").to(action: :index) }
      it { is_expected.to respond_with 200 }
      it { expect(assigns(:buses)).to match_array(bus) }
    end

    context "as admin" do
      before do
        sign_in(user, scope: :user)
        get :index, params: { bus_owner_id: busowner.id }
      end
      it { is_expected.to render_template("index") }
      it { is_expected.to route(:get, "/buses").to(action: :index) }
      it { is_expected.to respond_with 200 }
      it { expect(assigns(:buses)).to match_array(bus) }
    end
  end

  describe "GET #edit" do
    before do
      get :edit, params: { bus_owner_id: busowner.id, id: bus.id }
    end
    it { is_expected.to render_template("edit") }
    it { is_expected.to route(:get, "/buses/1/edit").to(action: :edit, id: 1) }
    it { is_expected.to respond_with 200 }
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Bus" do
        allow(BusOwner).to receive(:find).with(busowner.id.to_s).and_return(busowner)
        expect_any_instance_of(Bus).to receive(:save).and_return(true)

        post :create, params: { bus_owner_id: busowner.id, bus: attributes_for(:bus) }
        is_expected.to respond_with(:redirect)
        is_expected.to redirect_to(bus_owner_path(busowner))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved bus as @bus" do
        allow(BusOwner).to receive(:find).with(busowner.id.to_s).and_return(busowner)
        expect_any_instance_of(Bus).to receive(:save).and_return(false)

        post :create, params: { bus_owner_id: busowner.id, bus: attributes_for(:bus, total_seat: nil) }
        expect(assigns(:bus)).to be_a_new(Bus)
        is_expected.to respond_with(:unprocessable_entity)
        is_expected.to render_template(:new)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:valid_attributes) { attributes_for(:bus, name: "My new Bus") }
      it "updates the requested bus" do
        allow(BusOwner).to receive(:find).with(busowner.id.to_s).and_return(busowner)
        allow(busowner.buses).to receive(:find).with(bus.id.to_s).and_return(bus)
        allow(bus).to receive(:update).with(valid_attributes).and_return(true)

        patch :update, params: { bus_owner_id: busowner.id, id: bus.id, bus: valid_attributes }
        bus.reload
        expect(bus.name).to eq("My new Bus")
        is_expected.to respond_with(:redirect)
        is_expected.to redirect_to(bus_owner_bus_path(busowner, bus))
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { attributes_for(:bus, name: nil) }
      it "assigns the bus as @bus and re-renders the 'edit' template" do
        allow(BusOwner).to receive(:find).with(busowner.id.to_s).and_return(busowner)
        allow(busowner.buses).to receive(:find).with(bus.id.to_s).and_return(bus)
        allow(bus).to receive(:update).with(invalid_attributes).and_return(false)

        patch :update, params: { bus_owner_id: busowner.id, id: bus.id, bus: invalid_attributes }
        bus.reload
        expect(assigns(:bus)).to eq(bus)
        is_expected.to render_template(:edit)
        is_expected.to respond_with(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:newbus) { create :bus, bus_owner: busowner }
    it "deletes a bus" do
      expect(Bus.exists?(newbus.id)).to be true
      delete :destroy, params: { bus_owner_id: busowner.id, id: newbus.id }
      expect(Bus.exists?(newbus.id)).to be false
      expect(response).to redirect_to(bus_owner_buses_path(busowner))
    end
  end
end
