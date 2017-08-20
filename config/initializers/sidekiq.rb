require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq-status'
require "#{Rails.root}/lib/modules/sidekiq_calculations.rb"

# http://julianee.com/rails-sidekiq-and-heroku/
# https://github.com/jollygoodcode/jollygoodcode.github.io/issues/12

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["caw", "caw"]
end

ENV["REDISTOGO_URL"] ||= "redis://localhost:6379"

Sidekiq.configure_client do |config|
  sidekiq_calculations = SidekiqCalculations.new
  sidekiq_calculations.raise_error_for_env!

  config.redis = {
    url: ENV['REDISCLOUD_URL'],
    size: sidekiq_calculations.client_redis_size
  }
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

Sidekiq.configure_server do |config|
  sidekiq_calculations = SidekiqCalculations.new
  sidekiq_calculations.raise_error_for_env!

  config.options[:concurrency] = sidekiq_calculations.server_concurrency_size
  config.redis = {
    url: ENV['REDISCLOUD_URL']
  }
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
  Rails.application.config.after_initialize do
    Rails.logger.info("DB Connection Pool size for Sidekiq Server before disconnect is: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
    ActiveRecord::Base.connection_pool.disconnect!

    ActiveSupport.on_load(:active_record) do
      config = Rails.application.config.database_configuration[Rails.env]
      config['reaping_frequency'] = ENV['DATABASE_REAP_FREQ'] || 10 # seconds
      config['pool'] = ENV['WORKER_DB_POOL_SIZE'] || Sidekiq.options[:concurrency]
      ActiveRecord::Base.establish_connection(config)

      Rails.logger.info("DB Connection Pool size for Sidekiq Server is now: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
    end
  end
end
