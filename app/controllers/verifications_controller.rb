class VerificationsController < ApplicationController

  def show
    if User.find_by_verification_token(params[:id].to_s)
      @user = User.find_by_verification_token(params[:id].to_s)
      @user.update_attribute(:verified, true)
      sign_in @user unless current_user
      if @user.password_is_user_generated
        redirect_to root_path, notice: "Your account has been verified."
      else
        @user.generate_token(:password_reset_token)
        @user.password_reset_sent_at = DateTime.now
        @user.save!
        redirect_to edit_password_reset_url(@user.password_reset_token), notice: "Your account has been verified. Please create a password."
      end
    else
      redirect_to root_path, notice: "There was a problem verifying your account. Please contact support for more details."
    end
  end

end
