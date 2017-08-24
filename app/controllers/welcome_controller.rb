class WelcomeController < ApplicationController
  def index
    render json: Quote.paginate(:page => params[:page], :per_page => 300)
  end
end
