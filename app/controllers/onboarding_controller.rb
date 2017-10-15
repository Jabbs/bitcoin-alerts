class OnboardingController < ApplicationController
  before_action :redirect_signed_in_user

  def login
  end

  def signup
    @new_user = User.new
  end

  def password_reset
  end
end
