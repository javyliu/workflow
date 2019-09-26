class WelcomeController < ApplicationController
  skip_before_action :login_required

  def index
    Rails.logger.debug "-----RemoteIP-#{request.remote_ip}--X-Forwarded-For:#{request.env['HTTP_X_Forwarded_For']}--X-Real-Ip:#{request.env['HTTP_X_REAL_IP']}---HTTP_X_FORWARDED_FOR:#{request.env['HTTP_X_FORWARDED_FOR']}-"
  end
end
