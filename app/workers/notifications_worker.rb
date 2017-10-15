class NotificationsWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: 10, retry: false, failures: :exhausted

  def perform(channel_id)
    channel = Channel.find_by_id(channel_id)

    unless channel.has_sent_notifications_within_frequency_limit?
      notification_message = channel.rules.first.generate_message
      User.where(id: channel.subscriptions.pluck(:user_id)).each do |user|
        channel.channel_notifications.create!(user: user, message: notification_message)
        NotificationMailer.channel_alert_email(channel, user, notification_message).deliver_now if user.subscribed?
      end
    end
  end

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end
end
