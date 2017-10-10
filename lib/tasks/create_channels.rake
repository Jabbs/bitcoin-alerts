namespace :bitcoin do
  desc 'Create channels'
  task :create_channels => :environment do
    Currency.with_bittrex_data.each do |currency|
      directions = ["<i class='fa fa-arrow-up'></i>", "<i class='fa fa-arrow-down'></i>"]
      directions.each do |direction|
        [[2,4],[4,8]].each do |p|
          Channel.create(name: "#{direction} #{p[0].to_s}% from #{p[1].to_s}hr running average", currency_id: currency.id,
            description: Faker::Lorem.paragraph(rand(1..8)), frequency_in_minutes: p[1]*60,
            source_name: "Bittrex", source_url: "https://bittrex.com/home/api")
        end
      end
    end
  end
end
