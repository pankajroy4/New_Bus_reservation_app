class Bus < ApplicationRecord
  belongs_to :user
  has_many :reservations, dependent: :destroy
  has_many :seats, dependent: :destroy
  has_one_attached :main_image
  validates :name, :route, :registration_no, presence: true
  validates :total_seat, presence: true, numericality: { greater_than_or_equal_to: 10 }
  validates :registration_no, uniqueness: { message: "must be unique and govt. verified" }

  after_create :create_seats
  after_update :adjust_seats
  before_destroy :delete_seats

  scope :approved, -> { where(approved: true) }
  scope :search_by_name_or_route, ->(query) {
          sanitized_string = sanitize_sql_like(query)
          where("name LIKE ? OR route LIKE ?", "%#{sanitized_string}%", "%#{sanitized_string}%")
        }

  def disapprove!
    return unless approved?
    update(approved: false)
    reservations.delete_all
    send_approval_email
    true
  end

  def approve!
    return if approved?
    update(approved: true)
    send_approval_email
    true
  end

  private

  def delete_seats
    Seat.where(bus_id: id).delete_all
  end

  def create_seats(n = 1)
    seats = (n..total_seat).map do |seat|
      Seat.new(bus_id: id, seat_no: seat)
    end

    Seat.transaction do
      Seat.import(seats)
    end
  end

  def adjust_seats
    original_no_of_seat = seats.count
    if total_seat > original_no_of_seat
      create_seats(original_no_of_seat + 1)
    elsif total_seat < original_no_of_seat
      seats.where(bus_id: id).where(" seat_no > ? ", total_seat).destroy_all
    end
  end

  def send_approval_email
    ApprovalEmailsJob.set(wait: 1.week).perform_later(self)
  end
end

# NOTE: delete_all method will bypass model validations and callbacks ,So in case ,we do not want to bypass validations and callbacks ,use destroy, like:
# seats.where(bus_id: id).where("seat_no > ?", total_seat).destroy_all

# Behind the scence for =>  has_one_attached :main_image
# has_one :main_image_attachment, dependent: :destroy
# has_one :main_image_blob, through:  :main_image_attachment
