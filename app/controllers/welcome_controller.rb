class WelcomeController < ApplicationController
  def index
    render json: Quote.all
  end
end
