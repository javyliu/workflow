class UsersController < ApplicationController
  #before_action :set_user, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  skip_load_resource only: [:home,:confirm,:kaoqing]

  # GET /users
  # GET /users.json
  def index
    #@users = User.all
    @users = @users.page(params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show
    drop_page_title("我的签到记录")
    drop_breadcrumb
  end


  def home
    drop_page_title("我的考勤")
    drop_breadcrumb
    @to_be_confirms = if current_user.pending_tasks
                        current_user.pending_tasks.group_by do |item|
                          item[0..3]
                        end
    end

    @my_journals = current_user.journals.order("id desc").page(params[:page]).select("journals.*,checkin,checkout").joins("inner join checkinouts on update_date = rec_date and journals.user_id = checkinouts.user_id ")

  end

  #确认考勤完成,删除该用户待确认任务
  def confirm
    #unless current_user.pending_tasks.include?(params[:task])
    #  raise CanCan::AccessDenied.new("已确认或未授权", home_users_path,params[:task])
    #end
    @task = Task.init_from_subject(params[:task])

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

    @need_update = current_user.pending_tasks.include?(@task.task_name) || params[:cmd] == "update"
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

    @date = @task.date
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
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
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
      params.require(:user).permit(:uid, :user_name, :email, :department, :title, :expire_date, :dept_code, :mgr_code, :password_digest, :role_group, :remember_token, :remember_token_expires_at)
    end

end
