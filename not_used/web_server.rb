require 'rack'
Rack::Handler::WEBrick.run Rack::Directory.new('./'), :Port => 7081,:Host => '192.168.0.252'

=begin
require 'socket'
webserver = TCPServer.new('192.168.0.252',7081)
base_dir = Dir.new(".")
while(session = webserver.accept)
  session.print "HTTP/1.1 200/OK\r\nContent-type:text/html\r\n\r\n"

  request = session.gets
  #"GET /users HTTP/1.1\r\n"
  puts request.inspect
  trimmedrequest = request.gsub(/GET \//,'').gsub(/ HTTP.*/,'')
  puts trimmedrequest

  if trimmedrequest.chomp != ""
    begin
      base_dir = Dir.new("./#{trimmedrequest}".chomp)

      session.print "#{trimmedrequest}"

      session.print("#{base_dir}")

      base_dir.entries.each do |f|
        if File.directory? f
          session.print("<a href='#{f}'> #{f} </a>")
        else
          session.print("#{f}")
        end
      end
    rescue
      session.print("Directory does not exists!")

    end

  end


  session.close
end
=end
