class UsersController < ApplicationController
  before_action :signed_in_user, only: [:settings, :update]

  def create
    check_for_spam
    @user = User.new(user_params)
    if params[:user][:password].blank?
      @user.password = SecureRandom.urlsafe_base64
      @user.password_is_user_generated = false
    end
    @user.username = @user.email.split("@").try(:first).try(:first, 25)
    if @user.save
      sign_in @user
      @user.send_verification_email
      redirect_to root_path
    else
      redirect_to root_path, alert: "There was an issue creating your account. If you already have an account please log in."
    end
  end

  def settings
  end

  def update
    @user = User.find_by_id(params[:id])
    subscribed_box_checked = params[:user][:subscribed].present? && params[:user][:subscribed] == "on"
    if @user.update_attributes(user_params.merge("subscribed" => subscribed_box_checked))
      redirect_to settings_path, notice: "Your account has been updated."
    else
      redirect_to settings_path, alert: "There was an issue updating your account. Please message #{t('application.root.email')} for assistance."
    end
  end

  private

  def check_for_spam
    raise ActionController::RoutingError.new('Not Found') if !params[:blank].blank? # Spam catcher
    raise ActionController::RoutingError.new('Not Found') if !params[:name_1].blank? # Spam catcher
    raise ActionController::RoutingError.new('Not Found') if !params[:email_1].blank? # Spam catcher
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username, :subscribed)
  end
end
