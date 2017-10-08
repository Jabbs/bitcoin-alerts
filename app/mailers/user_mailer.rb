class UserMailer < ActionMailer::Base
  default from: "#{I18n.t('application.root.name')} <no-reply@bitcoinalerts.com>"

  def verification_email(user)
    @user = user
    mail(to: "<#{user.email}>", subject: "Verify your #{I18n.t('application.root.name')} account")
    @user.verification_sent_at = DateTime.now
    @user.save
  end

end
