class QuotesController < ApplicationController

  def index
    currency = "BTC"
    currency = params[:currency].upcase if params[:currency].present?
    @quotes = Quote.where(currency_pair: currency + "-USD").order("traded_at asc")

    @comparison_quote_lookback_quote_count = 48 # 4 hours
    @percent_change_threshold = 3
    @size = 5000
    @currency_name = "Bitcoin"

    if currency == "LTC"
      @comparison_quote_lookback_quote_count = 24 # 2 hours
      @percent_change_threshold = 2
      @size = 60
      @currency_name = "Litecoin"
    elsif currency == "ETH"
      @comparison_quote_lookback_quote_count = 24 # 2 hours
      @percent_change_threshold = 2
      @size = 400
      @currency_name = "Ethereum"
    end
  end
end
