class VerificationsController < ApplicationController
  before_action :signed_in_user, only: [:resend]

  def show
    if User.find_by_verification_token(params[:id].to_s)
      @user = User.find_by_verification_token(params[:id].to_s)
      @user.update_attribute(:verified, true)
      sign_in @user unless current_user
      if @user.password_is_user_generated
        redirect_to root_path, notice: "Your email has been verified."
      else
        @user.generate_token(:password_reset_token)
        @user.password_reset_sent_at = DateTime.now
        @user.save!
        redirect_to edit_password_reset_url(@user.password_reset_token), notice: "Your email has been verified. Please create a password."
      end
    else
      redirect_to root_path, notice: "There was a problem verifying your account. Please contact support for more details."
    end
  end

  def resend
    current_user.send_verification_email
    redirect_to root_path, notice: "A verification email has been sent to #{current_user.email}"
  end
end
