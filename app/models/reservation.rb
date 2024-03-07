class Reservation < ApplicationRecord
  belongs_to :bus
  belongs_to :user
  belongs_to :seat
  validates :date, presence: { message: "should be given" }
  validate :bus_must_be_approved
  validate :date_not_in_past
  
  module Exception
    class InvalidTransaction < StandardError; end
  end

  def date_not_in_past
    if date.present? && date < Date.today
      errors.add(:date, "should not be in the past")
    end
  end


  def bus_must_be_approved
    unless bus&.approved?
      errors.add(:base, "Bus must be approved to create a reservation")
    end
  end

  def self.display_searched_date_seats(bus, date)
    reservations_on_searched_date = bus.reservations.where(date: date)
    seat_ids_booked = reservations_on_searched_date.pluck(:seat_id)
    bus.seats.where(id: seat_ids_booked)
  end

  def self.check_booked?(seat_id, bus_id, date)
    result = Reservation.where(seat_id: seat_id, date: date, bus_id: bus_id)
    !(result.blank?)
  end

  def self.create_reservations(user_id, bus_id, seat_ids, date)
    return false if seat_ids.blank?
    reservations = seat_ids.map do |seat_id|
      return false if Reservation.check_booked?(seat_id, bus_id, date)
      Reservation.new(user_id: user_id, bus_id: bus_id, seat_id: seat_id, date: date)
    end
    # Reservation.transaction do
    #   Reservation.import(reservations.compact) # Using 'activerecord-import' gem
    # end
    # true

    errors = []
    begin
      ActiveRecord::Base.transaction do
        res = Reservation.import(reservations.compact, validate: true)
        if res.failed_instances.present?
          res.failed_instances.each do |invalid_record|
            errors << invalid_record.errors.full_messages
          end
          raise Exception::InvalidTransaction
        end
      end
    rescue Exception::InvalidTransaction
      return errors
    end
    return true
  end
end