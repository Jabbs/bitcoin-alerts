class SessionsController < ApplicationController

  def create
    @session_user = User.find_by_email(params[:email].to_s.downcase)
    if @session_user && @session_user.authenticate(params[:password].to_s)
      sign_in @session_user
      redirect_to root_path
    else
      redirect_to login_path, alert: "Invalid email or password."
    end
  end

  def destroy
    cookies.delete(:ghost_user)
    cookies.delete(:auth_token)
    redirect_to root_path
  end

end
