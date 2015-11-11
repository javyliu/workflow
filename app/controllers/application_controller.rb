class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user

  before_action :login_required
  include JavyTool::Breadcrumb
  include JavyTool::ConstructQuery
  include JavyTool::CustomError

  rescue_from CanCan::AccessDenied,AccessDenied do |exception|
    respond_to do |format|
      format.js do
        render :js => "alert('#{exception.message}')",content_type: Mime::JS
      end
      format.json do
        render :json => exception.message.kind_of?(Hash) ? exception.message : {error: exception.message}
      end
      format.any do
        response.headers.delete('Content-Disposition')
        return_url = exception.action =~ /^\// ? exception.action : root_url
        #return_url = exception.action.presence || root_url
        redirect_to return_url, alert: exception.message
      end
    end

  end

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    respond_to do |format|
      format.html do
        redirect_to "sessions/new", alert: exception.message
      end
      format.json do
        render :json => exception.message.kind_of?(Hash) ? exception.message : {error: exception.message}
      end
      format.js {render :js => "alert('#{exception.message}')"}
    end

  end

  def login_required
    !!current_user || access_denied
  end

  def current_user
    @current_user ||= (login_from_session || login_from_cookie) unless @current_user == false
  end
  # Store the given user id in the session.
  def current_user=(new_user)
    session[:user_id] = new_user ? new_user.id : nil
    @current_user = new_user || false
  end

  def access_denied
    reset_session
    respond_to do |format|
      format.html do
        store_location
        redirect_to new_session_path
      end
      format.js do
        render :json =>  {logined: false},content_type: Mime::JSON
      end
      format.json{render :json => {logined: false}}
    end
  end

  private

  def store_location
    session[:return_to] = request.fullpath
  end

  def login_from_session
    self.current_user = User.find_by(uid: session[:user_id]) if session[:user_id]
  end


  def login_from_cookie
    user = cookies[:auth_token] && User.find_by(remember_token: cookies[:auth_token])
    if user && user.remember_token?
      cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
    end
    self.current_user=user
    @current_user
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
