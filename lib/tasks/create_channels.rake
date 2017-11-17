namespace :bitcoin do
  desc 'Create channels'
  task :create_channels => :environment do
    Currency.with_bittrex_data.each do |currency|
      directions = ["<i class='fa fa-arrow-up'></i>", "<i class='fa fa-arrow-down'></i>"]
      directions.each do |direction|
        [[2,4],[4,8]].each do |p|
          c = Channel.create(name: "#{direction} #{p[0].to_s}% from #{p[1].to_s}hr running average", currency_id: currency.id,
            description: Faker::Lorem.paragraph(rand(1..8)), frequency_in_minutes: p[1]*60,
            source_name: "Bittrex", source_url: "https://bittrex.com/home/api")
        end
      end
    end
  end

  task :create_barrier_channels => :environment do
    Currency.with_bittrex_data.each do |currency|
      [
        ["falls below", "passed_meaningful_barrier_floor?"],
        ["rises above", "passed_meaningful_barrier_ceiling?"]
      ].each do |context|
        name = "price #{context[0]} any psychological support level"
        description = "Stay notified when the price #{context[0]} a level of psychological support. Support levels calculations are best described by a few examples: $655 ($700 &amp; $650), $3.12 ($3.5 &amp; 3), and $5842 ($6000 &amp; $5500)"
        source_url = "https://bittrex.com/Market/Index?MarketName=" + currency.selected_market_name
        source_name = "Bittrex"
        frequency_in_minutes = 1440
        channel = Channel.create!(currency_id: currency.id, name: name, description: description, source_url: source_url, source_name: source_name, frequency_in_minutes: frequency_in_minutes)
        channel.rules.create!(
          operator: "or",
          comparison_table: "bittrex_market_summaries",
          comparison_table_column: "last",
          comparison_table_scope_method: "market_name",
          comparison_table_scope_value: currency.selected_market_name,
          custom_function: context[1]
        )
      end
    end
  end

  task :create_ceiling_and_floor_channels => :environment do
    Currency.with_bittrex_data.each do |currency|
      last_amount = BittrexMarketSummary.where(market_name: currency.selected_market_name).where("created_at > ?", 5.minutes.ago).order(:id).try(:last).try(:last)
      next unless last_amount.present?

      next_ceiling = Numbers.next_meaningful_amount(last_amount, "up")
      name = "price surpasses the latest resistance level of #{Numbers.format_number_to_str_decimal(next_ceiling)} #{currency.paired_symbol}"
      unless Channel.where(active: true).find_by_name(name)
        description = "Get notified when the price of #{currency.name} surpasses the latest resistance level of #{Numbers.format_number_to_str_decimal(next_ceiling)} #{currency.paired_symbol}."
        source_url = "https://bittrex.com/Market/Index?MarketName=" + currency.selected_market_name
        source_name = "Bittrex"
        frequency_in_minutes = 120
        frequency_type = "one-time"
        channel = Channel.create!(currency_id: currency.id, name: name, description: description, source_url: source_url, source_name: source_name,
                    frequency_in_minutes: frequency_in_minutes, frequency_type: frequency_type)
        channel.rules.create!(
          operator: "or",
          comparison_table: "bittrex_market_summaries",
          comparison_table_column: "last",
          comparison_table_scope_method: "market_name",
          comparison_table_scope_value: currency.selected_market_name,
          ceiling: next_ceiling
        )
      end

      next_floor = Numbers.next_meaningful_amount(last_amount, "down")
      name = "price falls below the latest support level of #{Numbers.format_number_to_str_decimal(next_floor)} #{currency.paired_symbol}"
      unless Channel.where(active: true).find_by_name(name)
        description = "Get notified when the price of #{currency.name} falls below the latest support level of #{Numbers.format_number_to_str_decimal(next_floor)} #{currency.paired_symbol}."
        source_url = "https://bittrex.com/Market/Index?MarketName=" + currency.selected_market_name
        source_name = "Bittrex"
        frequency_in_minutes = 120
        frequency_type = "one-time"
        channel = Channel.create!(currency_id: currency.id, name: name, description: description, source_url: source_url, source_name: source_name,
                    frequency_in_minutes: frequency_in_minutes, frequency_type: frequency_type)
        channel.rules.create!(
          operator: "or",
          comparison_table: "bittrex_market_summaries",
          comparison_table_column: "last",
          comparison_table_scope_method: "market_name",
          comparison_table_scope_value: currency.selected_market_name,
          floor: next_floor
        )
      end

    end
  end

end
