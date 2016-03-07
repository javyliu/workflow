class UsersController < ApplicationController
  #before_action :set_user, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  skip_load_resource only: [:home,:confirm,:kaoqing,:change_pwd,:manual_unify_delete,:unify_update]


  #c_holiday_year
  #c_sick_leaver
  #c_ab_point
  #c_switch_leave

  # GET /users
  # GET /users.json
  def index
    #@users = User.all
    params.permit!
    con_hash,like_hash = construct_condition(:user,like_ary: [:user_name,:email])
    drop_page_title("用户管理")
    drop_breadcrumb
    @date = Date.today
    @users = @users.not_expired.where(con_hash).where(like_hash) if con_hash || like_hash
    @users = @users.not_expired.page(params[:page]).includes(:dept,:roles)
    #@user = current_user.decorate
    respond_to do |format|
      format.html {  }
      format.js {render partial: "items",object: @users, content_type: Mime::HTML}
    end

  end

  # GET /users/1
  # GET /users/1.json
  def show
    drop_breadcrumb("用户管理",users_path)
    drop_page_title("用户详情")
    drop_breadcrumb
  end


  def home
    drop_page_title("我的考勤")
    drop_breadcrumb
    @to_be_confirms = current_user.group_pending_tasks
    #@user = current_user.decorate
    @my_journals = current_user.journals.where("check_type = 10 or dval != 0").order("update_date desc,id desc").page(1).per(10)
    .select("journals.*,checkin,checkout,episodes.id episode_id,episodes.holiday_id,episodes.state")
    .joins("left join checkinouts on update_date = rec_date and journals.user_id = checkinouts.user_id
    left join episodes on journals.user_id = episodes.user_id and ck_type = check_type and state <> 2 and update_date >= date(start_date) and update_date <= end_date ")
    @my_journals.instance_variable_set(:@total_count,@my_journals.except(:joins,:order,:offset,:select,:limit).count)

  end

  #确认考勤完成,删除该用户待确认任务
  def confirm
    #unless current_user.pending_tasks.include?(params[:task])
    #  raise CanCan::AccessDenied.new("已确认或未授权", home_users_path,params[:task])
    #end
    @task = Task.init_from_subject(params[:task])
    _date = Date.parse(@task.date)
    _today = Date.today
    #小于上月25号的考勤不能再作修改,27号以后不能再修改本月考勤
    limit_day = OaConfig.setting(:limit_day_of_month).to_i
    if _date < _today.last_month.change(day:limit_day) || (_today.day > limit_day && _date.day < limit_day)
      raise CanCan::AccessDenied.new("该日考勤已过了确认时间",kaoqing_users_path("dept") ,params[:task])
    end

    @task.update(:state,Task::Completed)#设置任务完成
    @task.remove(all: true)

    respond_to do |format|
      format.html { redirect_to kaoqing_users_path(@task) }
      format.json { render json: @task ,location: kaoqing_users_path(@task)}
    end
  end

  #部门考勤
  def kaoqing
    #a hack to see all manager's confirm form
    @user = current_user
    if current_user.id == "1416" and params[:mock].present?
      @user = User.find(params[:mock])
    end

    #如果未指定task，则新建一个昨日task
    @task = Task.init_from_subject(params[:task]) || Task.new("F001",@user.id,date: Date.yesterday)
    @date = Date.parse(@task.date)
    #大于当日可确认考勤，提示无数据
    if @date > Date.yesterday
      raise CanCan::AccessDenied.new("无考勤数据！",kaoqing_users_path("dept") ,params[:task])
    end

    _today = Date.today
    limit_day = OaConfig.setting(:limit_day_of_month).to_i
    @need_update = @user.pending_tasks.include?(@task.task_name) || params[:cmd] == "update"
    _is_expired =  @date < _today.last_month.change(day:limit_day) || (_today.day > limit_day && @date.day < limit_day)
    if _is_expired
      @task.remove(all: true)
      flash.now[:alert] = '该日考勤已过期，如需修改请联系人事部门。'
    end
    @hide_edit = @need_update || _is_expired
    is_mine = @task.leader_user_id == @user.id
    #if (@user.roles & ["department_manager","admin"]).blank? && !is_mine
    if !is_mine
      raise CanCan::AccessDenied.new("已确认或未授权", home_users_path,params[:task])
    end

    drop_page_title("部门考勤")
    drop_breadcrumb("我的考勤",home_users_path)
    drop_breadcrumb

    @to_be_confirm = @user.pending_tasks.inject([]) do |tasks,item|
      tasks << item if item =~ /^F001/
      tasks
    end

    @rule = AttendRule.find(@user.leader_data[1]) rescue Rails.logger.debug{"error_no_leader_data:#{@user.id}"}

    @user = @user.decorate
    @user.report_titles = ReportTitle.where(id: @rule.title_ids).order("ord,id")

  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    drop_breadcrumb("用户管理",users_path)
    drop_page_title("用户编辑")
    drop_breadcrumb
  end

  #更改密码
  def change_pwd
    @user = current_user
    drop_breadcrumb("我的考勤",home_users_path)
    drop_page_title("更改密码")
    drop_breadcrumb
  end

  # POST /users
  # POST /users.json
  def create
    #@user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: '操作成功!' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update

    respond_to do |format|
      if @user.update(user_params)
        msg = "账号#{@user.email_en_name}考勤系统操作成功！"
        @user.remember_token = nil
        @user.remember_token_expires_at = nil
        #统一修改密码
        if params[:commit] == '统一修改'
          msg = @user.unify_update.flatten.delete_if{|item| PwdDb::NoUserReg =~ item}.join("<br>")
          #msg = '操作已提交，请等待密码修改结果！'
          Usermailer.unify_update(@user.id,"密码更改通知","您于 #{Time.now.strftime("%F %T")} 修改公司账号密码为 #{@user.password.sub(/^(.).*(.)$/,'\1******\2')}").deliver_later
        end
        format.html { redirect_to (can?(:manage,User) ? @user : home_users_path),notice: msg }
        format.json { render :show, status: :ok, location: @user }
      else
        flash.now[:alert] = @user.errors.full_messages.join("<br>")
        format.html { render can?(:change_pwd,User) ? :change_pwd : :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  #更改密码，只允许固定密码用户更改密码
  #用于管理员手动统一清除账号
  def manual_unify_delete
    drop_breadcrumb("用户管理",users_path)
    drop_page_title("统一删除账号")
    drop_breadcrumb
  end

  #重置密码
  #post
  def unify_reset
    @user.password = SecureRandom.urlsafe_base64(8)
    @user.remember_token = nil
    @user.remember_token_expires_at = nil
    if @user.save
      msgs = @user.unify_update.flatten.delete_if{|item| PwdDb::NoUserReg =~ item}.join("<br>")
      Usermailer.unify_update(@user.id,"密码重置通知","您的公司账号密码于 #{Time.now.strftime("%F %T")} 被重置为 #{@user.password}").deliver_later
    else
      msgs = @user.errors.full_messages.join(" ")
    end

    respond_to do |format|
      format.js { render text: msgs,content_type: Mime::HTML }
    end

  end

  #删除账号
  #put
  #delete
  def unify_delete
    msgs = if params[:_method] == "delete"
             if params[:name] != params[:name_confirmation]
               "用户名输入不一致！"
             else
               current_user.unify_update(true,name: params[:name]).flatten.join("<br>")
             end
           else
             @user = User.find(params[:id])
             @user.unify_update(true).flatten.join("<br>")
           end
    respond_to do |format|
      format.html { redirect_to manual_unify_delete_users_path,notice: msgs }
      format.js { render text: msgs,content_type: Mime::HTML }
    end
  end
  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      #params.require(:user).permit(:uid, :user_name, :email, :department, :title, :expire_date, :dept_code, :mgr_code, :password_digest, :role_group, :remember_token, :remember_token_expires_at)
      params.require(:user).permit(:uid, :password,:mgr_code,:title,:password_confirmation,:dept_code,role_ids: [],department: [] )
    end

end
