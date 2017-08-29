class TradesController < ApplicationController
  def index
    render json: Trade.paginate(:page => params[:page], :per_page => 300)
  end
end
