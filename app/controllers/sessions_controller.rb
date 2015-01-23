class SessionsController < ApplicationController
  def new
    if current_user
      redirect_back_or_default(params[:return_to] || '/')
    else
      flash[:alert] = params[:message] if params[:message]
    end
  end

  def create
    user = User.find_by(email: params[:email]).try(:authenticate,params[:password])
    respond_to do |format|
      if user
        self.current_user = user
        if params[:remember_me] == "1"
          user.remember_me unless user.remember_token?
          cookies[:auth_token] = { :value => user.remember_token , :expires => user.remember_token_expires_at }
        end
        flash[:notice] = '登录成功'
        format.html { redirect_back_or_default("/checkinouts/me")}
        format.json { render json: {ok: 1,user_name: user.user_name} }
      else
        flash.now[:alert] = "邮件或密码不匹配"
        format.html { render :new }
        format.json { render json: user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    self.current_user.forget_me if current_user
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default(request[:return_to] || "/")
  end
end
