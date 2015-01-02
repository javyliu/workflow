class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user


  def authenticate
    !!current_user || access_denied
  end


  def current_user
    @current_user ||= login_from_session  if @current_user != false
  end

  # Store the given user id in the session.
  def current_user=(new_user)
    session[:user_id] = new_user ? new_user.id : nil
    @current_user = new_user || false
  end

  def login_from_session
    #Rails.logger.info("--------------login session")
    self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
  end

 # def admin?(user)
 #   user.admin?
 # end



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
    session[:return_to] = request.referer
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
