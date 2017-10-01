require 'net/http'
require 'json'

namespace :bitcoin do
  desc 'Get quotes from app'
  task :pull_data => :environment do
    pull_data("Quote")
    pull_data("BittrexMarketSummary")
    pull_data("PoloniexQuote")
  end

  def pull_data(class_name)
    klass = class_name.constantize
    page = klass.count/300
    page = 1 if page == 0
    while page != nil
      url = "https://bitcoinalerts.herokuapp.com/#{class_name.underscore.pluralize}?page=" + page.to_s
      uri = URI(url)
      response = Net::HTTP.get(uri)
      json = JSON.parse(response)
      json.each do |attrs|
        klass.create!(attrs) unless klass.find_by_id(attrs["id"]).present?
      end
      page += 1
      page = nil if json.empty?
      puts "#{klass}, page #{page}"
    end
  end
end
