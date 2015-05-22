Rails.application.config.middleware.tap do |config|
    config.delete 'Rack::Lock'    # 多线程加锁，多进程模式下无意义
    config.delete 'Rack::Runtime' # 记录X-Runtime（方便客户端查看执行时间）
    config.delete 'ActionDispatch::RequestId' # 记录X-Request-Id（方便查看请求在群集中的哪台执行）
    config.delete 'ActionDispatch::RemoteIp'  # IP SpoofAttack
    config.delete 'ActionDispatch::Callbacks' # 在请求前后设置callback
    config.delete 'ActionDispatch::Head'      # 如果是HEAD请求，按照GET请求执行，但是不返回body
    config.delete 'Rack::ConditionalGet'      # HTTP客户端缓存才会使用
    config.delete 'Rack::ETag'    # HTTP客户端缓存才会使用
    config.delete 'ActionDispatch::BestStandardsSupport' # 设置X-UA-Compatible, 在nginx上设置
    #config.middleware.insert_after("Rack::Runtime",'ResponseTimer')
    #config.middleware.use "ResponseTimer"
    #swap is replace and not switch
    #config.middleware.swap("ResponseTimer",::Rack::Head)

end

