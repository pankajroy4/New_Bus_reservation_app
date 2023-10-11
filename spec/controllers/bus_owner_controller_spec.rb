require "rails_helper"

RSpec.describe BusOwnersController, type: :controller do
  let(:bus_owner) { create(:bus_owner) }
  let(:admin) { create(:admin) }

  before { sign_in(admin, scope: :user) }

  describe "GET #index" do
    it "renders the index template in HTML format" do
      get :index
      expect(assigns(:bus_owners)).to match_array(bus_owner)
      is_expected.to route(:get, "/bus_owners").to(action: :index)
      is_expected.to respond_with 200
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "renders the show template in HTML format" do
      sign_in(bus_owner, scope: :bus_owner)
      get :show, params: { id: bus_owner.id }
      expect(assigns(:bus_owner)).to match(bus_owner)
      is_expected.to route(:get, "/bus_owners/1").to(action: :show, id: 1)
      is_expected.to respond_with 200
      expect(response).to render_template(:show)
    end
  end
end
