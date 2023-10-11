
require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Bus,  type: :model do
  let(:bus) { create(:bus) }

  let(:user) { create(:user) }
  
  let(:duplicate_bus) { bus.dup }
  
  context "Associations" do
    it { is_expected.to belong_to(:bus_owner).class_name("User").with_foreign_key("bus_owner_id") }
    it { is_expected.to have_many(:reservations).dependent(:destroy) }
    it { is_expected.to have_many(:seats).dependent(:destroy) }
    it { is_expected.to have_one_attached(:main_image) } 
  end

  context "Validations" do 
    it "is valid with valid attributes" do
      expect(bus).to be_valid
    end                                    

    it "is not valid without a name" do
      bus.name = ""
      expect(bus).not_to be_valid
    end

    it "is not valid without a route" do
      bus.route = ""
      expect(bus).not_to be_valid
    end

    it "is not valid without a total_seat" do
      bus.total_seat = nil
      expect(bus).not_to be_valid
    end

    it "is not valid with a duplicate registration_no" do
      expect(duplicate_bus).not_to be_valid
    end

  end 

  context "Callbacks" do
    it "creates seats after creating a bus" do
      expect(bus.seats.count).to eq(bus.total_seat)
    end

    it "adjusts seats when total_seat is updated" do
      bus.update(total_seat: 40)
      expect(bus.seats.count).to eq(40)
    end

    it "deletes seats and reservations when a bus is destroyed" do
      bus.approved = true
      selected_seats = bus.seats.sample(10) 
      selected_seats.map do |seat|
        create(:reservation, user: user, bus: bus, seat: seat)
      end
      expect(bus.reservations.count).to eq(10)
      bus.destroy
      expect(bus.seats.count).to eq(0)
      expect(bus.reservations.count).to eq(0)
    end
  end

  context "Scopes" do
    it "returns approved buses" do      
      approved_bus = FactoryBot.create(:bus, :approved_bus)
      expect(Bus.approved).to match_array(approved_bus)
    end

    it "do not return unapproved bus" do 
      expect(Bus.approved).not_to match_array(bus)
    end

    it "searches by name or route" do
      expect(Bus.search_by_name_or_route("Volvo Bus")).to match_array(bus)
      expect(Bus.search_by_name_or_route("Patna - Delhi")).to match_array(bus)
      expect(Bus.search_by_name_or_route("Mybus")).to be_empty
    end
  end

  context "Methods" do
    it "approves and send email" do
      bus.approved = false
      expect {bus.approve!}.to have_enqueued_job(ApprovalEmailsJob).on_queue("default")
      expect(bus.approved).to be_truthy
    end

    it "disapproves and delete all reservations and send email" do
      bus.approved = true
      selected_seats = bus.seats.sample(15) 
      selected_seats.map do |seat|
        create(:reservation, user: user, bus: bus, seat: seat)
      end
      expect(bus.reservations.count).to eq(15)
      expect{bus.disapprove! }.to have_enqueued_job(ApprovalEmailsJob).on_queue("default")
      expect(bus.approved).to be_falsey
      expect(bus.reservations.count).to eq(0)
    end
  end

end
