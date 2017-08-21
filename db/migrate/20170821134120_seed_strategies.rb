class SeedStrategies < ActiveRecord::Migration
  def change
    [
      { name: "Decrease of 4% looking back 8 hours", lookback_hours: 8, percent_change: 4, percent_change_direction: "decrease" },
      { name: "Decrease of 5% looking back 10 hours", lookback_hours: 10, percent_change: 5, percent_change_direction: "decrease" },
      { name: "Decrease of 8% looking back 16 hours", lookback_hours: 16, percent_change: 8, percent_change_direction: "decrease" },
      { name: "Decrease of 10% looking back 16 hours", lookback_hours: 24, percent_change: 10, percent_change_direction: "decrease" }
    ].each do |attrs|
      Strategy.create!(attrs) unless Strategy.find_by_name(attrs[:name]).present?
    end
  end
end
