namespace :bitcoin do
  desc 'Create channels'
  task :create_channels => :environment do
    Currency.where.not(color_hexidecimal: nil).where.not(symbol: ["BCH"]).first(20).each do |currency|
      directions = ["<i class='fa fa-arrow-up'></i>", "<i class='fa fa-arrow-down'></i>"]
      directions.each do |direction|
        [[2,4],[4,8]].each do |p|
          Channel.create(name: "#{direction} #{p[0].to_s}% from #{p[1].to_s}hr running average", currency_id: currency.id)
        end
      end
    end
  end
end
