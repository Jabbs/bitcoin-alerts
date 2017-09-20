class ChartsController < ApplicationController

  def index
    date = DateTime.now - 24.hours
    @markets = ["BTC-1ST", "BTC-2GIVE", "BTC-ABY", "BTC-ADT", "BTC-ADX", "BTC-AEON", "BTC-AGRS", "BTC-AMP", "BTC-ANT", "BTC-APX"]
    @prices = BittrexMarketSummary.where(market_name: "BTC-1ST").where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:last)
  end

  def show
    dates = []
    dates << "16-9-2017 12pm".to_datetime.in_time_zone("Central Time (US & Canada)")
    dates << "17-9-2017 12pm".to_datetime.in_time_zone("Central Time (US & Canada)")
    dates << "18-9-2017 12pm".to_datetime.in_time_zone("Central Time (US & Canada)")
    dates << "19-9-2017 12pm".to_datetime.in_time_zone("Central Time (US & Canada)")
    @prices_by_day = []
    @volumes_by_day = []
    @labels_by_day = []
    @created = ""
    if params[:exchange] == 'poloniex'

    elsif params[:exchange] == 'bittrex'
      dates.each do |date|
        prices = BittrexMarketSummary.where(market_name: params[:currency_pair]).where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:last)
        labels = BittrexMarketSummary.where(market_name: params[:currency_pair]).where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:created_at)
        volumes = BittrexMarketSummary.where(market_name: params[:currency_pair]).where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:base_volume)
        labels = labels.map { |l| l.strftime("%-l:%M%P") }
        interval = params[:interval].present? ? params[:interval].to_i : 5
        prices = (interval-1).step(prices.size-1, interval).map { |i| prices[i] }
        currency_multiplier = 1
        if params[:currency_pair].include?("BTC-")
          currency_multiplier = Numbers.average(BittrexMarketSummary.where(market_name: "USDT-BTC").where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).pluck(:last))
        elsif params[:currency_pair].include?("ETH-")
          currency_multiplier = Numbers.average(BittrexMarketSummary.where(market_name: "USDT-ETH").where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).pluck(:last))
        end
        prices = prices.map { |i| i * currency_multiplier }
        volumes = (interval-1).step(volumes.size-1, interval).map { |i| volumes[i] * currency_multiplier }
        @labels = (interval-1).step(labels.size-1, interval).map { |i| labels[i] }
        @prices_by_day << prices
        @volumes_by_day << volumes
        @labels_by_day << date.strftime("%m/%d") + " (avg vol: #{Numbers.average(volumes).round})"
      end
      @created = BittrexMarketSummary.where(market_name: params[:currency_pair]).first.created.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y %-l:%M%P")
    elsif params[:exchange] == 'gdax'

    end
  end
end
