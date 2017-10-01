class PasswordResetsController < ApplicationController

  def create
    @no_breadcrumbs = true
    @forgot_pass_user = User.find_by_email(params[:email].to_s)
    if @forgot_pass_user
      @forgot_pass_user.send_password_reset
      redirect_to root_path, notice: "If email exists, password reset instructions have been sent."
    else
      redirect_to root_path, notice: "If email exists, password reset instructions have been sent."
    end
  end

  def edit
    if User.find_by_password_reset_token(params[:id].to_s)
      @user = User.find_by_password_reset_token!(params[:id].to_s)
    else
      redirect_to root_path, alert: "User was not found. Please contact our support team for more details."
    end
  end

  def update
    @no_breadcrumbs = true
    @user = User.find_by_password_reset_token(params[:id].to_s)
    if !@user.present? || !@user.password_reset_sent_at.present?
      redirect_to edit_password_reset_path, alert: "There was an issue creating your password. Please contact our support team for more details."
    elsif @user && @user.password_reset_sent_at < 2.hours.ago
      redirect_to root_path, alert: "Password reset has expired."
    elsif params[:user][:password].size < 6 || params[:user][:password_confirmation].size < 6
      @user.errors.add(:password, "must be at least 6 characters") if params[:user][:password].size < 6
      @user.errors.add(:password_confirmation, "must be at least 6 characters") if params[:user][:password_confirmation].size < 6
      render 'edit'
    elsif @user && @user.update_attributes(user_params.merge("password_is_user_generated" => true))
      sign_in @user
      redirect_to profile_or_dashboard_path, notice: "Your new password has been updated!"
    else
      redirect_to edit_password_reset_path, alert: "Invalid password/confirmation combination."
    end
  end

  private
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def profile_or_dashboard_path
      if current_user.is?("organizer") && current_user.organizations.any?
        organization_dashboard_path(current_user.organizations.last)
      else
        user_path(@user)
      end
    end
end
