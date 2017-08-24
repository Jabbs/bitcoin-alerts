namespace :bitcoin do
  desc 'Get quotes from app'
  task :destroy_old_quotes => :environment do
    if Rails.env.production?
      count = Quote.where("traded_at < ?", 48.hours.ago).count
      return if count == 0
      ((count/300)+2).times do
        Quote.where("traded_at < ?", 48.hours.ago).first(300).destroy_all
      end
    end
  end
end
