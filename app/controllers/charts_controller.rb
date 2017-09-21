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
    dates << "20-9-2017 12pm".to_datetime.in_time_zone("Central Time (US & Canada)")
    @prices_by_day = []
    @volumes_by_day = []
    @labels_by_day = []
    @created = ""
    if params[:exchange] == 'poloniex'

    elsif params[:exchange] == 'bittrex'
      dates.each do |date|
        prices = BittrexMarketSummary.where(market_name: params[:currency_pair]).where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:last)
        btc_prices = BittrexMarketSummary.where(market_name: "USDT-BTC").where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:last)
        eth_prices = BittrexMarketSummary.where(market_name: "USDT-ETH").where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:last)
        labels = BittrexMarketSummary.where(market_name: params[:currency_pair]).where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:created_at)
        volumes = BittrexMarketSummary.where(market_name: params[:currency_pair]).where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:base_volume)

        if params[:currency_pair].include?("BTC-")
          prices = (interval-1).step(prices.size-1, interval).map { |i| prices[i] * btc_prices[i] }
          volumes = (interval-1).step(volumes.size-1, interval).map { |i| volumes[i] * btc_prices[i] }
        elsif params[:currency_pair].include?("ETH-")
          prices = (interval-1).step(prices.size-1, interval).map { |i| prices[i] * eth_prices[i] }
          volumes = (interval-1).step(volumes.size-1, interval).map { |i| volumes[i] * eth_prices[i] }
        else
          prices = (interval-1).step(prices.size-1, interval).map { |i| prices[i] }
          volumes = (interval-1).step(volumes.size-1, interval).map { |i| volumes[i] }
        end
        interval = params[:interval].present? ? params[:interval].to_i : 5
        percent_change_minutes = params[:percent_change_minutes].present? ? params[:percent_change_minutes].to_i : 5
        @percent_changes = BittrexMarketSummary.where(market_name: params[:currency_pair]).where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).map { |bms| bms.percent_change(percent_change_minutes).round(2) }

        @labels = (interval-1).step(labels.size-1, interval).map { |i| labels[i].strftime("%-l:%M%P") }
        @prices_by_day << prices
        @volumes_by_day << volumes
        @labels_by_day << date.strftime("%m/%d") + " (vol: $#{Numbers.average(volumes).round})"
      end
      @created = BittrexMarketSummary.where(market_name: params[:currency_pair]).first.created.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y %-l:%M%P")
    elsif params[:exchange] == 'gdax'

    end
  end
end
