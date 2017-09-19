class ChartsController < ApplicationController

  def index
    date = DateTime.now - 24.hours
    @markets = ["BTC-1ST", "BTC-2GIVE", "BTC-ABY", "BTC-ADT", "BTC-ADX", "BTC-AEON", "BTC-AGRS", "BTC-AMP", "BTC-ANT", "BTC-APX"]
    @prices = BittrexMarketSummary.where(market_name: "BTC-1ST").where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:last)
  end
end
