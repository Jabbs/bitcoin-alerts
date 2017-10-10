class PasswordResetsWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: 10, retry: false, failures: :exhausted

  def perform(user_id)
    user = User.find_by_id(user_id)
    if user
      user.generate_token(:password_reset_token)
      user.save
      UserMailer.password_reset_email(user).deliver_now
    end
  end

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end
end
