class OrderBookItemsController < ApplicationController
  def index
    render json: OrderBookItem.paginate(:page => params[:page], :per_page => 300)
  end
end
