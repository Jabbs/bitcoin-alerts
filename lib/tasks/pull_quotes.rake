require 'net/http'
require 'json'

namespace :bitcoin do
  desc 'Get quotes from app'
  task :pull_quotes => :environment do
    # url = 'https://api.spotify.com/v1/search?type=artist&q=tycho'
    # uri = URI(url)
    # response = Net::HTTP.get(uri)
    # JSON.parse(response)

  end
end
