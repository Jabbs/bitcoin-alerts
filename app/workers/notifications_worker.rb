class NotificationsWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: 10, retry: false, failures: :exhausted

  def perform(channel_id)
    channel = Channel.find_by_id(channel_id)

    unless channel.has_sent_notifications_within_frequency_limit?
      User.where(id: channel.subscriptions.pluck(:user_id)).each do |user|
        NotificationMailer.channel_alert_email(channel, user).deliver_now
        channel.channel_notifications.create!(user: user)
      end
    end
  end

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end
end
