class QuotesController < ApplicationController

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
      starting_at = 7.days.ago
      @quotes = Quote.where("traded_at > ?", starting_at).where(currency_pair: currency + "-USD").order("traded_at asc")
    end

    @lookback_hours = 1
    @lookback_quotes = 1
    @percent_change_threshold = 1
    @running_price_average_minutes = 20
    @multiplier = 5

    if currency == "BTC"
      @max = 5500
      @min = 3700
    elsif currency == "LTC"
      @min = 35
      @max = 55
    elsif currency == "ETH"
      @max = 350
      @min = 250
    end
  end
end
