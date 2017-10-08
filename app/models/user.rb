class User < ActiveRecord::Base
  has_secure_password

  validates :email, presence: true, uniqueness: true

  before_create { generate_token(:auth_token) }

  has_many :subscriptions

  def send_verification_email
    VerificationWorker.perform_async(self.id)
  end
end
