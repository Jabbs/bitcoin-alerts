class WelcomeController < ApplicationController
  def index
    currency = "BTC"
    currency = params[:currency].upcase if params[:currency].present?
    @simulation = Simulation.find_by_id(params[:simulation_id])
    @simulation_buy_quote_ids = []
    @simulation_sell_quote_ids = []
    if @simulation.present?
      @simulation_buy_quote_ids = @simulation.orders.select { |o| o.side == "buy" }.map { |o| o.quote_id }
      @simulation_sell_quote_ids = @simulation.orders.select { |o| o.side == "sell" }.map { |o| o.quote_id }
      @quotes = Quote.where(id: [@simulation.starting_quote_id..@simulation.ending_quote_id]).where(currency_pair: currency + "-USD").order("traded_at asc")
    else
      starting_at = "27-8-2017".to_datetime.beginning_of_day
      ending_at = "27-8-2017".to_datetime.end_of_day
      @quotes = Quote.where("traded_at >= ?", starting_at).where("traded_at <= ?", ending_at).where(currency_pair: currency + "-USD").order("traded_at asc")
    end

    @visual_interval = 1 # minutes
    @lookback_minutes = 1000
    @percent_change_threshold = 5
    @running_price_average_minutes = 10

    if currency == "BTC"
      @max = 5000
      @min = 2000
    elsif currency == "LTC"
      @min = 35
      @max = 90
    elsif currency == "ETH"
      @max = 350
      @min = 250
    end
  end
end
