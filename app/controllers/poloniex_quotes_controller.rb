class PoloniexQuotesController < ApplicationController
  def index
    render json: PoloniexQuote.paginate(:page => params[:page], :per_page => 300)
  end
end
