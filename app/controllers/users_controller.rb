class UsersController < ApplicationController
  #before_action :set_user, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  skip_load_resource only: [:home,:confirm,:kaoqing,:change_pwd]


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
    @users = @users.not_expired.where(con_hash).where(like_hash) if con_hash || like_hash
    @users = @users.not_expired.page(params[:page]).includes(:dept)
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
    @my_journals = current_user.journals.where("update_date >= ? and check_type = 10 or dval != 0",2.months.ago.to_date).order("update_date desc,id desc").page(params[:page])
    .select("journals.*,checkin,checkout,episodes.id episode_id,episodes.holiday_id,episodes.state")
    .joins("left join checkinouts on update_date = rec_date and journals.user_id = checkinouts.user_id
    left join episodes on journals.user_id = episodes.user_id and ck_type = check_type and state <> 2 and update_date >= date(start_date) and update_date <= end_date ")

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
    if _date < _today.change(day:26,month: _today.month - 1) || (_today.day > 26 && _date.day < 26)
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

    #如果未指定task，则新建一个昨日task
    @task = Task.init_from_subject(params[:task]) || Task.new("F001",current_user.id,date: Date.yesterday)
    @date = Date.parse(@task.date)
    if @date > Date.yesterday
      raise CanCan::AccessDenied.new("无考勤数据！",kaoqing_users_path("dept") ,params[:task])
    end

    _today = Date.today
    @need_update = current_user.pending_tasks.include?(@task.task_name) || params[:cmd] == "update"
    @hide_edit = @need_update || @date < _today.change(day:26,month: _today.month - 1) || (_today.day > 26 && @date.day < 26)
    is_mine = @task.leader_user_id == current_user.id
    if (current_user.roles & ["department_manager","admin"]).blank? && !is_mine
      raise CanCan::AccessDenied.new("已确认或未授权", home_users_path,params[:task])
    end

    drop_page_title("部门考勤")
    drop_breadcrumb("我的考勤",home_users_path)
    drop_breadcrumb

    @to_be_confirm = current_user.pending_tasks.inject([]) do |tasks,item|
      tasks << item if item =~ /^F001/
      tasks
    end

    @rule = AttendRule.find(current_user.leader_data[1])

    self.current_user = current_user.decorate
    current_user.report_titles = ReportTitle.where(id: @rule.title_ids).order("ord,id")

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

  #更改密码，只允许固定密码用户更改密码
  def change_pwd
    @user = current_user
    drop_breadcrumb("我的考勤",home_users_path)
    drop_page_title("更改密码")
    drop_breadcrumb
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
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
        format.html { redirect_to (can?(:manage,User) ? @user : home_users_path), notice: "操作成功！"}
        format.json { render :show, status: :ok, location: @user }
      else
        flash.now[:alert] = @user.errors.full_messages
        format.html { render can?(:change_pwd,User) ? :change_pwd : :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
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
      params.require(:user).permit(:uid, :password,:mgr_code,:title,:password_confirmation,roles: [] )
    end

end
