require "rails_helper"

RSpec.describe HomesController, type: :controller do
  let(:busowner) { create(:bus_owner) }
  let(:bus1) { create(:bus, user: busowner, approved: true, name: "Red Bus") }
  let(:bus2) { create(:bus, user: busowner, approved: true, name: "Volvo Bus") }

  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(assigns(:approved_buses)).to match_array([bus1, bus2])
      is_expected.to route(:get, "/").to(action: :index)
      is_expected.to respond_with 200
      expect(response).to render_template(:index)
    end
  end

  describe "GET #search" do
    it "renders the search template" do
      get :search, params: { user_query: bus1.name }
      is_expected.to route(:get, "/searched_bus").to(action: :search)
      expect(assigns(:approved_buses)).to match([bus1])
      expect(response).to have_http_status(200)
      expect(response).to render_template(:search)
    end
  end
end