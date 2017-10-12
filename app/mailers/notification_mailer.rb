class NotificationMailer < ActionMailer::Base
  default from: "#{I18n.t('application.root.name')} <no-reply@bitalertsnow.com>"

  def channel_alert_email(channel, user)
    @channel = channel
    @currency = channel.currency
    @user = user
    @channel_name = name_with_icons_replaced(@channel.name)
    from = "#{@currency.name} Alert <no-reply@bitalertsnow.com>"
    mail(to: "<#{user.email}>", from: from, subject: @channel_name)
  end

  private

    def name_with_icons_replaced(name)
      new_name = name.gsub("<i class='fa fa-arrow-up'></i>", "up")
      new_name = new_name.gsub("<i class='fa fa-arrow-down'></i>", "down")
      new_name
    end
end
