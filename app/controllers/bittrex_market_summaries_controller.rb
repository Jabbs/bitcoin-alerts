class BittrexMarketSummariesController < ApplicationController
  def index
    render json: BittrexMarketSummary.paginate(:page => params[:page], :per_page => 300)
  end
end
