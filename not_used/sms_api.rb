require 'sinatra'
require 'tilt/erubis'
require 'net/http'

get '/' do
  erb :index
end

post '/send' do
  #halt erb(:login) unless params[:user]
  mobile = params[:mobile]
  content = "#{params[:content]}【stongnet】"
  url = "http://www.stongnet.com/sdkhttp/sendsms.aspx?"
  pa = {reg:"101100-WEB-HUAX-040478",pwd:"VOUIMCOZ",sourceadd:nil ,phone:mobile, content: content }

  msg = fetch(url+pa.to_query)
  logger.info(msg.inspect)

  erb :send, :locals => { :msg => msg }
end

class Hash
  def to_query(namespace = nil)
    collect do |key, value|
      "#{key}=#{ERB::Util.url_encode(value)}"
    end.compact * '&'
  end
end

private

def fetch(uri_str, limit = 3,method = :get,data=nil)
  return 'too many HTTP redirects' if limit == 0
  logger.info(uri_str)
  url = URI.parse(uri_str)
  response = begin
               Net::HTTP.start(url.host, url.port,open_timeout: 10) do |http|
                 http.send("request_#{method.to_s}",url.request_uri,data)
                 #http.request( method == :get ? Net::HTTP::Get.new(url.request_uri) : Net::HTTP::Post.new(url.request_uri))
               end
             rescue Net::OpenTimeout => e
               e.inspect
             rescue
               $!
             end

  case response
  when Net::HTTPSuccess then
    #binding.pry
    if response.content_type == 'application/json'
      JSON.parse(response.body).symbolize_keys
    else
      response.body.force_encoding("utf-8").split($/)
    end
  when Net::HTTPRedirection then
    location = response['location']
    warn "redirected to #{location}"
    fetch(location, limit - 1)
  else
    response.to_s
  end
end



__END__
@@ layout
<html>
<head>
<title>短信平台测试</title>
<meta charset="utf-8" />
<script src="http://www.pipgame.com/javascripts/jquery.min.js"></script>
</head>
  <body><%= yield %></body>
</html>

@@ index
<form action='/send' method="post">
  <label for='mobile'>手机号:</label>
  <input name='mobile' value='' /><br/>
  <label for='content'>发送内容:</label>
  <input name='content' value='' />
  <input type='submit' value="发送!" />
</form>


@@ send
<p><%= msg %></p>
