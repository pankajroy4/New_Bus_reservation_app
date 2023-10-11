class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :confirmable
  validates :name, presence: true
  validate :validate_registration_no, on: :create

  has_many :reservations, dependent: :destroy
  has_many :buses, dependent: :destroy

  enum role: { admin: 0, bus_owner: 1, user: 2 }
  scope :admin, -> { where(role: "admin") }
  scope :user, -> { where(role: "user") }
  scope :bus_owner, -> { where(role: "bus_owner") }

  def generate_otp
    self.otp = "%06d" % rand(10 ** 6)
    self.otp_sent_at = Time.now
    self.save!
    self.otp
  end

  def validate_registration_no
    if bus_owner? && registration_no.blank?
      errors.add(:registration_no, "can't be blank for bus owners")
    end
  end

  def valid_otp?(otp)
    return false if otp.blank? || otp_sent_at.nil?
    otp_age = Time.now - otp_sent_at
    return false if otp_age > 5.minutes
    otp == self.otp
  end

  def send_confirmation_instructions
    generate_otp
    UserMailer.custom_confirmation_instructions(self, confirmation_token, otp: otp).deliver_now
  end

  def generate_and_send_otp
    otp = generate_otp
    update(otp: otp)
    OtpVerificationMailer.otp_verification_mailer(self, otp).deliver_now
  end
end
