class AssaultsController < ApplicationController
  #before_action :set_assault, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:show]

  # GET /assaults
  # GET /assaults.json
  def index
    drop_page_title("我的申请")
    drop_breadcrumb("我的考勤",home_users_path)
    drop_breadcrumb
    @assaults = @assaults.rewhere(user_id: current_user.id).order("id desc").page(params[:page]).decorate
  end

  # GET /assaults/1
  # GET /assaults/1.json
  def show
    if /^\d+$/ =~ params[:task]
      @assault = Assault.find_by(id:params[:task])
      raise CanCan::AccessDenied.new("该申请不存在！",home_users_path ) unless @assault
      @task = Task.new("F003",vice_leader(@assault.user).id,date:@assault.created_at.to_date.to_s,mid:@assault.id)
    else
      @task =  Task.init_from_subject(params[:task])
      @assault = Assault.find_by(id:@task.mid)
      unless @assault
        @task.remove(all: true)
        raise CanCan::AccessDenied.new("该申请不存在！",home_users_path )
      end
    end

    unless @assault.user
      @task.remove(all: true)
      raise CanCan::AccessDenied.new("该员工已离职！",home_users_path )
    end
    #跨级审批时会报错，除非加上审批权限
    #authorize!(:show,@assault)
    @approved = @assault.approve
    #Rails.logger.info @approves.inspect
    #如果当前用户有审批任务
    #if current_user.pending_tasks.include?(@task.to_s)
    if current_user.pending_tasks.include?(@task.to_s) || can?(:approve,@assault) && @approved
     @approve = @assault.build_approve
    end

    respond_to do |format|
      format.html do
        drop_page_title("突击申请")
        drop_breadcrumb("我的考勤",home_users_path)
        drop_breadcrumb("我的申请",assaults_path)
        drop_breadcrumb
      end
      format.js do
        expires_now
        render template: 'assaults/show',content_type: Mime::HTML
      end
    end
  end

  # GET /assaults/new
  def new
    @assault.style = params[:style].to_i
    title = @assault.style == 0 ? "突击申请" : "取消突击申请"
    @date = Date.today
    drop_page_title(title)
    drop_breadcrumb("我的申请",assaults_path)
    drop_breadcrumb

    @users = User.where(uid: current_user.leader_data["user_ids"])


  end

  # GET /assaults/1/edit
  def edit
    drop_breadcrumb("我的申请",assaults_path)
    drop_page_title("编辑申请")
    drop_breadcrumb
    @date = Date.today
    @users = User.where(uid: current_user.leader_data["user_ids"])
  end

  # POST /assaults
  # POST /assaults.json
  def create
    @assault.user_id = current_user.id
    @assault.state = 0

    respond_to do |format|
      if @assault.save
        #生成任务
        leader_user = vice_leader(current_user)

        _task = Task.create("F003",leader_user.id,leader_user_id: leader_user.id,date: @assault.created_at.to_date.to_s,mid: @assault.id)
        #用于测试
        #_task1 = Task.create("F003",current_user.id,leader_user_id: current_user.id,date: @assault.created_at.to_date.to_s,mid: @assault.id)
        Rails.logger.info _task.task_name
        #发送邮件
        Usermailer.assault_approve(_task.task_name).deliver_later

        format.html { redirect_to assaults_path, notice: '提交成功，请等待审批!' }
        format.json { render :show, status: :created, location: @assault }
      else
        drop_page_title("突击申请")
        drop_breadcrumb("我的申请",assaults_path)
        drop_breadcrumb
        @users = User.where(uid: current_user.leader_data["user_ids"])
        @date = Date.today
        flash.now[:alert] = @assault.errors.full_messages.join("\n")
        format.html { render :new }
        format.json { render json: @assault.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assaults/1
  # PATCH/PUT /assaults/1.json
  def update
    #raise CanCan::AccessDenied.new("不能修改已审批的申请！",assaults_path ) if @assault.state > 0
    respond_to do |format|
      if @assault.update(assault_params)
        format.html { redirect_to @assault, notice: 'Assault was successfully updated.' }
        format.json { render :show, status: :ok, location: @assault }
      else
        format.html { render :edit }
        format.json { render json: @assault.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assaults/1
  # DELETE /assaults/1.json
  def destroy
    @assault.destroy
    respond_to do |format|
      format.html { redirect_to assaults_url, notice: 'Assault was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_assault
    @assault = Assault.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def assault_params
    params.require(:assault).permit(:cate, :description, :start_date,:end_date,:style,employees:[])
  end

  #返回副总领导
  def vice_leader(user)
    user.vice_leader
  end

end
