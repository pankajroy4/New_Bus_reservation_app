require "rails_helper"

RSpec.describe AdminsController, type: :controller do
  let(:user) { create(:admin) }
  let(:busowner) { create(:bus_owner) }
  let(:bus) { create(:bus, bus_owner: busowner) }

  before { sign_in user }

  describe "GET #show" do
    it "renders the show template in HTML format" do
      get :show, params: { id: user.id }
      expect(response).to render_template(:show)
    end
  end

  describe "POST #approve" do
    it "approves a bus in Turbo Stream format" do
      post :approve, params: { bus_owner_id: busowner.id, id: bus.id }, format: :turbo_stream
      expect(response).to be_successful
      is_expected.to render_template("admins/approve")
    end
  end

  describe "POST #disapprove" do
    it "disapproves a bus in Turbo Stream format" do
      post :disapprove, params: { bus_owner_id: busowner.id, id: bus.id }, format: :turbo_stream
      expect(response).to be_successful
      is_expected.to render_template("admins/disapprove")
    end
  end
end
