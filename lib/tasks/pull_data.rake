require 'net/http'
require 'json'

namespace :bitcoin do
  desc 'Get quotes from app'
  task :pull_data => :environment do

    pull_data("Quote")
    pull_data("Trade")
    pull_data("OrderBook")
    pull_data("OrderBookItem")

    def pull_data(class_name)
      klass = class_name.constantize
      page = klass.count/300
      page = 1 if page == 0
      while page != nil
        url = "https://bitcoinalerts.herokuapp.com/#{class_name.downcase.pluralize}?page=" + page.to_s
        uri = URI(url)
        response = Net::HTTP.get(uri)
        json = JSON.parse(response)
        json.each do |attrs|
          klass.create!(attrs) unless klass.find_by_id(attrs["id"]).present?
        end
        page += 1
        page = nil if json.empty?
      end
    end

  end
end
