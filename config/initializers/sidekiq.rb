Sidekiq.configure_server do |config|
  config.redis = {url: ENV['RedisUrl']}

  #重新设置连接池大小
  ActiveRecord::Base.configurations[Rails.env]['pool'] = 20
  ActiveRecord::Base.establish_connection

  # 或者
  #
  #sconfig = Rails.application.config.database_configuration[Rails.env]
  #sconfig['pool']            = 100
  #ActiveRecord::Base.establish_connection sconfig
  #
end
Sidekiq.configure_client do |config|
  config.redis = {url: ENV['RedisUrl'],size: 1}
end
