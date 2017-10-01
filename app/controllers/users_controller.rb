class UsersController < ApplicationController
  def create
    check_for_spam
    @user = User.new(user_params)
    if params[:user][:password].blank?
      @user.password = SecureRandom.urlsafe_base64
      @user.password_is_user_generated = false
    end
    if @user.save
      sign_in @user
      @user.send_verification_email
      redirect_to root_path
    else
      redirect_to root_path, alert: "There was an issue creating your account. If you already have an account please log in."
    end
  end

  private

  def check_for_spam
    raise ActionController::RoutingError.new('Not Found') if !params[:blank].blank? # Spam catcher
    raise ActionController::RoutingError.new('Not Found') if !params[:name_1].blank? # Spam catcher
    raise ActionController::RoutingError.new('Not Found') if !params[:email_1].blank? # Spam catcher
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
