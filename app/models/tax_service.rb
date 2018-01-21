require 'csv'

class TaxService < ActiveRecord::Base

  def self.calculate
    ActiveRecord::Base.logger.level = 1
    Lot.delete_all
    @row_number = 0
    symbols = ["USD", "BTC", "LTC", "ETH", "LSK", "NEO", "XRP", "BTG"]
    @report = []
    trezor_times = []

    CSV.foreach("lib/taxes/transactions.csv", headers: false, :encoding => 'windows-1251:utf-8') do |row|
      next unless row[0].present?
      @row_number += 1
      puts "-------------------------------------------------"
      puts "ROW: #{@row_number}"
      puts "-------------------------------------------------"
      date              = row[0].split(" ")[0]
      time              = row[0].split(" ")[1]
      trx_datetime_str  = ("20" + date.split("/")[2] + "-" + date.split("/")[0] + "-" + date.split("/")[1] + " #{time}")
      @transaction_time  = trx_datetime_str.to_datetime
      @source_account    = row[2]
      @receiving_account = row[3]
      @usd_sell          = row[4].to_f
      @usd_buy           = row[5].to_f.abs
      @usd_transfer      = row[6].to_f
      @btc_sell          = row[7].to_f
      @btc_buy           = row[8].to_f
      @btc_transfer      = row[9].to_f
      @ltc_sell          = row[10].to_f
      @ltc_buy           = row[11].to_f
      @ltc_transfer      = row[12].to_f
      @eth_sell          = row[13].to_f
      @eth_buy           = row[14].to_f
      @eth_transfer      = row[15].to_f
      @lsk_sell          = row[16].to_f
      @lsk_buy           = row[17].to_f
      @lsk_transfer      = row[18].to_f
      @neo_sell          = row[19].to_f
      @neo_buy           = row[20].to_f
      @neo_transfer      = row[21].to_f
      @xrp_sell          = row[22].to_f
      @xrp_buy           = row[23].to_f
      @xrp_transfer      = row[24].to_f
      @usd_fee           = row[25].to_f
      @btc_fee           = row[26].to_f
      @usd_fmv           = row[27].to_f
      @btc_fmv           = row[28].to_f
      @gdax_btc_price    = row[29].to_f
      @gdax_ltc_price    = row[30].to_f
      @gdax_eth_price    = row[31].to_f
      @source_account_symbol    = symbols.select { |s| @source_account.include?(s) }.try(:first)
      @receiving_account_symbol = symbols.select { |s| @receiving_account.include?(s) }.try(:first)

      # TODO: TEZOR TRANSFERS
      # TODO: BTG

      trezor_times << [@row_number, trx_datetime_str] if @receiving_account.include?("TREZOR")

      if @source_account_symbol == @receiving_account_symbol
        next
      elsif @source_account_symbol == "USD"
        # bought an asset with USD
        lot = Lot.create!(receiving_account_symbol: @receiving_account_symbol, aquired_asset_amount: TaxService.asset_buy, remaining_asset_amount: TaxService.asset_buy, usd_cost: @usd_buy, transaction_time: @transaction_time)
        TaxService.print_lot(lot)
      elsif @receiving_account_symbol == "USD"
        # sold an asset to USD
        TaxService.sell_source_asset
      else
        # sold an asset for an asset (first sell then buy)
        if ["LSK", "NEO", "XRP", "BTG"].include?(@source_account_symbol) && @receiving_account_symbol == "BTC"
          @usd_sell = @btc_buy * @gdax_btc_price
          @usd_buy = @btc_buy * @gdax_btc_price
        else
          @usd_sell = TaxService.asset_sell * TaxService.price_fmv
          @usd_buy  = TaxService.asset_sell * TaxService.price_fmv
        end
        if @source_account_symbol == "BTG"
          lot = Lot.create!(receiving_account_symbol: "BTG", aquired_asset_amount: 7.8548132, remaining_asset_amount: 7.8548132, usd_cost: 0, transaction_time: @transaction_time)
          TaxService.print_lot(lot)
        end
        TaxService.sell_source_asset
        if @source_account_symbol != "BTG"
          lot = Lot.create!(receiving_account_symbol: @receiving_account_symbol, aquired_asset_amount: TaxService.asset_buy, remaining_asset_amount: TaxService.asset_buy, usd_cost: @usd_buy, transaction_time: @transaction_time)
          TaxService.print_lot(lot)
        end
      end
    end
    puts "-------------------------------------------------"
    puts "-------------------------------------------------"
    puts "-------------------------------------------------"
    trezor_times
  end

  def self.calculate_price_fmv(transaction_time_str, symbol="BTC-USD")
    date = transaction_time_str.split(" ")[0]
    time = transaction_time_str.split(" ")[1]
    transaction_time  = ("20" + date.split("/")[2] + "-" + date.split("/")[0] + "-" + date.split("/")[1] + " #{time}").to_datetime
    transaction_time = transaction_time - 6.hours # CST to UTC
    quote = Quote.where(currency_pair: symbol).where("created_at < ?", transaction_time).order("created_at desc").first
    Quote.get_previous_quotes(quote, 10).first.price
  end

  def self.price_fmv
    if @source_account_symbol == "BTC"
      @gdax_btc_price
    elsif @source_account_symbol == "LTC"
      @gdax_ltc_price
    elsif @source_account_symbol == "ETH"
      @gdax_eth_price
    end
  end

  def self.print_lot(lot)
    puts "-> LOT (#{lot.id}), " + lot.receiving_account_symbol + ", " + lot.aquired_asset_amount.to_s + ", " + lot.usd_cost.to_s + ", " + lot.transaction_time.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y")
  end

  def self.sell_source_asset
    sell_price = @usd_sell / TaxService.asset_sell
    sell_amount_left = TaxService.asset_sell
    # byebug if @row_number == 8
    Lot.where(receiving_account_symbol: @source_account_symbol).where.not(remaining_asset_amount: 0).order(:id).each do |lot|
      next if sell_amount_left == 0
      if lot.remaining_asset_amount >= sell_amount_left
        cost = (sell_amount_left / lot.aquired_asset_amount) * lot.usd_cost
        proceeds = sell_price * sell_amount_left
        r = [@source_account_symbol, lot.transaction_time, @transaction_time, proceeds, cost, lot.id, "meh"]
        @report << r
        TaxService.print_report_row(r)
        new_remaining_asset_amount = lot.remaining_asset_amount - sell_amount_left
        lot.update_attribute(:remaining_asset_amount, new_remaining_asset_amount)
        sell_amount_left = 0
      else
        proceeds = sell_price * lot.remaining_asset_amount
        r = [@source_account_symbol, lot.transaction_time, @transaction_time, proceeds, lot.usd_cost, lot.id, "psh"]
        @report << r
        TaxService.print_report_row(r)
        sell_amount_left = sell_amount_left - lot.remaining_asset_amount
      end
    end
  end

  def self.print_report
    @report.each do |r|
      TaxService.print_report_row(r)
    end
  end

  def self.print_report_row(r)
    puts r[0] + ", " + r[1].in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y") + ", " + r[2].in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y") + ", " + r[3].round(2).to_s + ", " + r[4].round(2).to_s + ", " + (r[3] - r[4]).round(2).to_s + ", LOT: #{r[5]}" + ", #{r[6]}"
  end

  def self.asset_buy
    if @receiving_account_symbol == "BTC"
      @btc_buy
    elsif @receiving_account_symbol == "LTC"
      @ltc_buy
    elsif @receiving_account_symbol == "ETH"
      @eth_buy
    elsif @receiving_account_symbol == "LSK"
      @lsk_buy
    elsif @receiving_account_symbol == "NEO"
      @neo_buy
    elsif @receiving_account_symbol == "XRP"
      @xrp_buy
    elsif @receiving_account_symbol == "BTG"
      7.8548132
    end
  end

  def self.asset_sell
    if @source_account_symbol == "BTC"
      @btc_sell.abs
    elsif @source_account_symbol == "LTC"
      @ltc_sell.abs
    elsif @source_account_symbol == "ETH"
      @eth_sell.abs
    elsif @source_account_symbol == "LSK"
      @lsk_sell.abs
    elsif @source_account_symbol == "NEO"
      @neo_sell.abs
    elsif @source_account_symbol == "XRP"
      @xrp_sell.abs
    elsif @source_account_symbol == "BTG"
      7.8548132
    end
  end

end
