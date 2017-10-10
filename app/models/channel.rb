class Channel < ActiveRecord::Base
  belongs_to :currency
  has_many :rules, dependent: :destroy
  has_many :subscriptions
  has_many :channel_notifications

  validates :name, presence: true

  accepts_nested_attributes_for :rules, allow_destroy: true

  def self.process_all
    Channel.where(active: true).each do |channel|
      channel.process
    end
  end

  def has_sent_notifications_within_frequency_limit?
    return false unless self.frequency_in_minutes.present?
    self.channel_notifications.where("created_at > ?", DateTime.now - self.frequency_in_minutes.minutes).any?
  end

  def process
    is_passing = false
    self.rules.with_or_operator.each do |rule|
      next if is_passing
      is_passing = rule.is_passing?
    end
    NotificationsWorker.perform_async(self.id) if is_passing
  end
end
