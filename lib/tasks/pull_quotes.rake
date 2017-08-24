require 'net/http'
require 'json'

namespace :bitcoin do
  desc 'Get quotes from app'
  task :pull_quotes => :environment do
    page = 1
    while page != nil
      url = "https://bitcoinalerts.herokuapp.com/?page=" + page.to_s
      uri = URI(url)
      response = Net::HTTP.get(uri)
      json = JSON.parse(response)
      json.each do |quote_attrs|
        Quote.create!(quote_attrs) unless Quote.find_by_id(quote_attrs["id"]).present?
      end
      page += 1
      page = nil if json.empty?
    end
  end
end
