require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:busowner1) { create(:bus_owner) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
  end

  describe "GET #index" do
    it "renders the index template only when access by admin" do
      get :index
      # expect(assigns(:users)).to eq([admin, user1, user2, busowner1])
      is_expected.to route(:get, "/users").to(action: :index)
      is_expected.to respond_with 200
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "renders the show template" do
      get :show, params: { id: admin.id }
      # is_expected.to route(:get, "/users/1").to(action: :show, id: admin.id)
      expect(assigns(:user)).to match(admin)
      expect(response).to have_http_status(200)
      expect(response).to render_template(:show)
    end
  end
end
