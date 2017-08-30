class OrderBooksController < ApplicationController
  def index
    render json: OrderBook.paginate(:page => params[:page], :per_page => 300)
  end
end
