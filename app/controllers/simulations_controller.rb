class SimulationsController < ApplicationController
  def index
    @simulation = params[:simulation].present? ? Simulation.find(params[:simulation]) : Simulation.last
    currency_pair = @simulation.scheme.strategies.buy.first.currency_pair
    starting_at = 10.days.ago
    @orders = @simulation.orders
    @simulation_quote_ids = @simulation.orders.map { |o| o.quote_id }
    @quotes = Quote.where("traded_at > ?", starting_at).where(currency_pair: currency_pair).order("traded_at asc")
    if currency_pair == "BTC-USD"
      @size = 5500
    elsif currency_pair == "LTC-USD"
      @size = 60
    elsif currency_pair == "ETH-USD"
      @size = 400
    end
  end
end
