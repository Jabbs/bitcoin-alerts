class VerificationWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: 10, retry: false, failures: :exhausted

  def perform(user_id)
    user = User.find_by_id(user_id)
    if user
      user.generate_token(:verification_token)
      user.save
      UserMailer.verification_email(user).deliver_now
    end
  end

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end
end
