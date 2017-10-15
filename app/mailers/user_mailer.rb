class UserMailer < ActionMailer::Base
  default from: "#{I18n.t('application.root.name')} <no-reply@bitcoinalerts.com>"

  def verification_email(user)
    @user = user
    mail(to: "<#{user.email}>", subject: "Verify your email address")
    @user.verification_sent_at = DateTime.now
    @user.save!
  end

  def password_reset_email(user)
    @user = user
    mail(to: "<#{user.email}>", subject: "Set Your Password")
    @user.password_reset_sent_at = DateTime.now
    @user.save!
  end

  def channel_alert_email(channel, user)
    @channel = channel
    @user = user
    mail(to: "<#{user.email}>", subject: channel.name)
  end
end
