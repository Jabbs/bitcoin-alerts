class User < ActiveRecord::Base
  has_secure_password

  validates :email, presence: true, uniqueness: true

  before_create { generate_token(:auth_token) }

  has_many :subscriptions
  has_many :channel_notifications

  def send_verification_email
    VerificationWorker.perform_async(self.id)
  end

  def send_password_reset
    PasswordResetsWorker.perform_async(self.id)
  end
end
