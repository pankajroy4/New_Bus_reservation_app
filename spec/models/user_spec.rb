require "rails_helper"
require "shoulda/matchers"

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  context "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    # it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
    it { should define_enum_for(:role).with_values(admin: 0, bus_owner: 1, user: 2) }
  end

  context "Associations" do
    it { should have_many(:reservations).dependent(:destroy) }
  end

  context "User type" do
    it "has a defined user type" do
      expect(user.role).to eq("user")
    end
  end

  context "send_confirmation_instructions" do
    it "generates OTP and sends confirmation instructions mail when user created" do
      ActionMailer::Base.deliveries.clear
      user = create(:user, confirmed_at: nil)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(user.otp).not_to be_nil
      expect(ActionMailer::Base.deliveries.first.to).to match_array(user.email)
    end
  end

  context "generate_and_send_otp" do
    it "generates OTP and sends OTP verification mail" do
      expect(user).to receive(:generate_otp).and_return(user.otp)
      otp_verification_mailer = double(deliver_now: true)
      expect(OtpVerification).to receive(:otp_verification).with(user, user.otp).and_return(otp_verification_mailer)

      user.generate_and_send_otp
    end
  end
end

# context "generate_and_send_otp" do
#   it "generates OTP, updates user, and sends OTP verification email" do
#     # user = create(:user) # Create a user

#     # Stubs the OtpVerification.otp_verification method to capture arguments
#     allow(OtpVerification).to receive(:otp_verification) do |user_arg, otp_arg|
#       expect(user_arg).to eq(user)
#       expect(otp_arg).to eq(user.otp)
#       double(deliver_now: true) # Return a double to simulate email delivery
#     end

#     # Call the generate_and_send_otp method
#     user.generate_and_send_otp

#     # Expectations
#     expect(user.otp).not_to be_nil # OTP should be generated and updated
#     expect(OtpVerification).to have_received(:otp_verification).once # Method should be called once
#   end
# end
