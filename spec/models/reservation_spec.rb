
require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Reservation, type: :model do
  let(:bus_owner) { create(:bus_owner) }
  let(:bus) { create(:bus, bus_owner: bus_owner, approved: true) }
  let(:user) { create(:user) }
  let(:seat) { create(:seat, bus: bus) }
  let(:date) { Date.today }

  describe 'validations' do
    it { should validate_presence_of(:date).with_message('should be given') }

    context 'when the bus is not approved' do
      before { bus.update(approved: false) }

      it 'is not valid' do
        reservation = build(:reservation, bus: bus, user: user, seat:  bus.seats.first , date: date)
        expect(reservation).not_to be_valid
      end
    end
  end

  context "Associations" do
    it { should belong_to(:bus) }
    it { should belong_to(:user) }
    it { should belong_to(:seat) }
  end

  context "Methods" do
    it "displays available seats on a specific date" do
      reservation = create(:reservation, bus: bus, user: user, seat: bus.seats.first, date: Date.today)
      available_seats = Reservation.display_searched_date_seats(bus, reservation.date)
      expect(available_seats).not_to match_array(bus.seats.first)
    end

    it "checks if a seat is booked for a bus on a specific date" do
      reservation = create(:reservation, bus: bus, user: user, seat: bus.seats.last, date: Date.today)
      expect(Reservation.check_booked?(bus.seats.last.id, bus.id, reservation.date)).to be true
      expect(Reservation.check_booked?(bus.seats.last.id, bus.id, reservation.date + 1.day)).to be false
    end

    it "returns false for blank seat_ids" do
      expect(Reservation.create_reservations(user.id, bus.id, [], Date.today)).to be false
    end
  end
end
