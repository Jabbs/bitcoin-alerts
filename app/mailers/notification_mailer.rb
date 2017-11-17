class NotificationMailer < ActionMailer::Base
  default from: "#{I18n.t('application.root.name')} <no-reply@bitalertsnow.com>"

  def channel_alert_email(channel, user, notification_message)
    @channel = channel
    @currency = channel.currency
    @user = user
    @channel_name = name_with_icons_replaced(@channel.name)
    @notification_message = notification_message
    from = "#{@currency.name} Alert <no-reply@bitalertsnow.com>"
    mail(to: "<#{user.email}>", from: from, subject: @currency.name + " " + @channel_name)
  end

  def daily_summary_email(user, date, lookback_days=7)
    @user = user
    @currency = Currency.find_by_name("Bitcoin")
    @daily_infos = BittrexMarketSummary.daily_info(date, lookback_days, @currency.selected_market_name)
    @high = @daily_infos.map { |d| d.high }.sort.last
    @low = @daily_infos.map { |d| d.low }.sort.first
    @vol_avg = BittrexMarketSummary.average_volume("USDT-BTC", 200)
    from = "#{@currency.name} Alert <no-reply@bitalertsnow.com>"
    mail(to: "<#{@user.email}>", from: from, subject: @currency.name + " Daily Update")
  end

  private

    def name_with_icons_replaced(name)
      new_name = name.gsub("<i class='fa fa-arrow-up'></i>", "up")
      new_name = new_name.gsub("<i class='fa fa-arrow-down'></i>", "down")
      new_name
    end
end
