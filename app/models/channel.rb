class Channel < ActiveRecord::Base
  belongs_to :currency
  has_many :rules, dependent: :destroy
  has_many :subscriptions
  has_many :channel_notifications

  validates :name, presence: true

  accepts_nested_attributes_for :rules, allow_destroy: true

  FREQUENCY_TYPES = ["continuous", "one-time"]

  def self.process_all
    Channel.where(active: true).each do |channel|
      channel.process
    end
  end

  def self.text_search(query)
    currency_id = Currency.where("name @@ :q", q: query).try(:first).try(:id)
    if query.present? && currency_id.present?
      self.where(currency_id: currency_id)
    elsif query.present?
      self.where("name @@ :q or description @@ :q", q: query)
    else
      self.all
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
    if is_passing
      NotificationsWorker.perform_async(self.id)
      self.deactivate if self.one_time_frequency?
    end
  end

  def deactivate
    self.update_column(:active, false)
  end

  def one_time_frequency?
    self.frequency_type == "one-time"
  end

  def continuous_frequency?
    self.frequency_type == "continuous"
  end
end
