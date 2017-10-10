class OnboardingController < ApplicationController
  def login
  end

  def signup
    @new_user = User.new
  end

  def password_reset
  end
end
