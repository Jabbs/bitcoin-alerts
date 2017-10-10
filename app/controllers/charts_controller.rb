class ChartsController < ApplicationController
  before_action :redirect_non_admin

  def index
    date = DateTime.now - 24.hours
    @markets = ["BTC-1ST", "BTC-2GIVE", "BTC-ABY", "BTC-ADT", "BTC-ADX", "BTC-AEON", "BTC-AGRS", "BTC-AMP", "BTC-ANT", "BTC-APX"]
    @prices = BittrexMarketSummary.where(market_name: "BTC-1ST").where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).pluck(:last)
  end

  def show
    dates = []
    dates << "21-9-2017 12pm".to_datetime.in_time_zone("Central Time (US & Canada)")
    dates << "22-9-2017 12pm".to_datetime.in_time_zone("Central Time (US & Canada)")
    @prices_by_day = []
    @volumes_by_day = []
    @labels_by_day = []
    @created = ""
    if params[:exchange] == 'poloniex'

    elsif params[:exchange] == 'bittrex'
      dates.each do |date|
        interval = params[:interval].present? ? params[:interval].to_i : 5
        percent_change_minutes = params[:percent_change_minutes].present? ? params[:percent_change_minutes].to_i : 5
        percent_changes = []; prices = []; @labels = []; volumes = [];
        BittrexMarketSummary.where(market_name: params[:currency_pair]).where("created_at >= ?", date.beginning_of_day).where("created_at <= ?", date.end_of_day).order(:id).each_with_index do |bms, index|
          if index % interval == 0
            percent_changes << bms.percent_change(percent_change_minutes).round(2) if params[:chart_type].present? && params[:chart_type] == "percent"
            if params[:currency_pair].include?("BTC-")
              prices << bms.last * bms.btc_price
              volumes << bms.base_volume * bms.btc_price
            elsif params[:currency_pair].include?("ETH-")
              prices << bms.last * bms.eth_price
              volumes << bms.base_volume * bms.eth_price
            else
              prices << bms.last
              volumes << bms.base_volume
            end
            @labels << bms.created_at.strftime("%-l:%M%P")
          end
        end
        if params[:chart_type].present? && params[:chart_type] == "percent"
          @prices_by_day << percent_changes
        else
          @prices_by_day << prices
        end
        @volumes_by_day << volumes
        @labels_by_day << date.strftime("%m/%d") + " (vol: $#{Numbers.average(volumes).round})"
      end
      @created = BittrexMarketSummary.where(market_name: params[:currency_pair]).first.created.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y %-l:%M%P")
    elsif params[:exchange] == 'gdax'

    end
  end
end
