require 'coinbase/exchange'
namespace :bitcoin do
  desc 'Get quote from Coinbase'
  task :get_quote => :environment do
    begin_time = DateTime.now
    Rails.logger.info "Starting sync. #{begin_time.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")}"
    CoinbaseService.sync_all_quotes
    # BittrexService.sync_market_summaries
    SlackService.send_alerts
    # Channel.process_all
    # Scheme.process(Quote.recent_quotes)
    end_time = DateTime.now
    Rails.logger.info "Completed sync. #{begin_time.to_i - end_time.to_i} seconds"
  end

  desc 'Check TD indicators'
  task :check_td_indicator => :environment do
    IndicatorService.send_slack_messages
  end

end
