
class ResponseTimer
  def initialize(app)
    @app = app
  end

  def call(env)
    @request = Rack::Request.new(env)
    #status,headers,_ = @app.call(env)
    #Rails.logger.info{ response.class}
    #Rails.logger.info{ response.instance_variable_get(:@body).class}
    if @request.path =~ /\A\/sl(\d+)\z/
      start = Time.now

      #ActiveRecord::Base.with_connection do |con|
      #  U

      #end

      u = User.first
      Rails.logger.info("========#{@request.path}==#{u.email}========in response")
      #['200',{"Content-type" => "text/html"},"<!-- Response Time: #{stop - start}-->\n".lines]# and return
      stop = Time.now
      Rails.logger.info("========#{stop-start} ms==========in response")
      Rack::Response.new{|res|res.redirect("http://baidu.com")}
    else
      @app.call(env)
    end
  end
end
