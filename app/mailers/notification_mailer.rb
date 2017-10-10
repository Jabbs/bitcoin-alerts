class NotificationMailer < ActionMailer::Base
  default from: "#{I18n.t('application.root.name')} <no-reply@bitcoinalerts.com>"

  def channel_alert_email(channel, user)
    @channel = channel
    @currency = channel.currency
    @user = user
    @channel_name = name_with_icons_replaced(@channel.name)
    subject = @currency.name + " Alert: " + @channel_name
    mail(to: "<#{user.email}>", subject: subject)
  end

  private

    def name_with_icons_replaced(name)
      new_name = name.gsub("<i class='fa fa-arrow-up'></i>", "up")
      new_name = new_name.gsub("<i class='fa fa-arrow-down'></i>", "down")
      new_name
    end
end
