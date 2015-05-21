require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Workflow
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Beijing'

    #set auto load paths
    #config.autoload_paths += %W(#{Rails.root}/app/models/chares_database/)
    config.autoload_paths += %W(#{Rails.root}/lib/)
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.available_locales  = ['en','zh-CN']
    config.i18n.default_locale = 'zh-CN'
    config.active_record.default_timezone = :local

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    #set backend adapter
    config.active_job.queue_adapter = :sidekiq

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.default_url_options = { host: 'kq.press5.cn'}
    #config.action_mailer.logger = nil
    config.action_mailer.smtp_settings = {
      address:              '114.251.179.140',
      port:                 25,
      domain:               'pipgame.com',
      user_name:            'y',
      password:             ENV['SMTP_PWD'],
      authentication:       'plain'
     }

    config.middleware.delete 'Rack::Lock'    # 多线程加锁，多进程模式下无意义
    #config.middleware.delete 'Rack::Runtime' # 记录X-Runtime（方便客户端查看执行时间）
    #config.middleware.delete 'ActionDispatch::RequestId' # 记录X-Request-Id（方便查看请求在群集中的哪台执行）
    config.middleware.delete 'ActionDispatch::RemoteIp'  # IP SpoofAttack
    #config.middleware.delete 'ActionDispatch::Callbacks' # 在请求前后设置callback
    #config.middleware.delete 'ActionDispatch::Head'      # 如果是HEAD请求，按照GET请求执行，但是不返回body
    config.middleware.delete 'Rack::ConditionalGet'      # HTTP客户端缓存才会使用
    config.middleware.delete 'Rack::ETag'    # HTTP客户端缓存才会使用
    config.middleware.delete 'ActionDispatch::BestStandardsSupport' # 设置X-UA-Compatible, 在nginx上设置
    #config.middleware.insert_after("Rack::Runtime",'ResponseTimer')
    #config.middleware.use "ResponseTimer"
    #swap is replace and not switch
    #config.middleware.swap("ResponseTimer",::Rack::Head)
  end
end
SITE_NAME="掌上明珠考勤系统"
