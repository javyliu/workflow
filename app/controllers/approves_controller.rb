class ApprovesController < ApplicationController
  #before_action :set_approfe, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource only: [:create,:update]

  # GET /approves
  # GET /approves.json
  def index
    @approves = Approve.all
  end

  # GET /approves/1
  # GET /approves/1.json
  def show
  end

  # GET /approves/new
  def new
    @approve = Approve.new
  end

  # GET /approves/1/edit
  def edit
  end

  # POST /approves
  # POST /approves.json
  PolyParam = Struct.new(:title,:class_name,:back_path)
  def create
    @approve = Approve.new(approve_params)
    @approve.user_id = current_user.id
    @approve.user_name = current_user.user_name

    @task = Task.init_from_subject(params[:task])

    #防止页面脚本提交过快，state 无值的情况
    if @approve.state.to_i == 0
      @approve.state = params[:commit] == "通过" ? 1 : 2
    end
    @approveable = @approve.approveable

    #unless current_user.pending_tasks.include?(@task.to_s)
    if  !current_user.pending_tasks.include?(@task.to_s) && cannot?(:approve,@approveable)
      raise CanCan::AccessDenied.new("已确认或未授权", home_users_path,@task.to_s)
    end

    if params[:updated_at] != @approveable.updated_at.to_s
      #Rails.logger.debug {"error:已被重新编辑"}
      @approve.errors.add(:base,'该申请已被重新编辑，请再次确认！')
    end

    @poly_params = PolyParam.new
    @poly_params.class_name = @approve.approveable_type

    respond_to do |format|
      if @approve.errors.size == 0 && @approve.save
        #当前任务完成,删除提醒任务
        @task.update(:state,Task::Completed)
        @task.remove(all: true)

        #更新假单或突击申请状态
        @approveable.state = self.send("approve_#{@poly_params.class_name.downcase}") #更新为审批中
        @approveable.save!(validate: false)

        #返回假单显示页面
        format.html { redirect_to @poly_params.back_path, notice: '审核成功.' }
        #只有假单审批才会有js format
        format.js {render js: "$('#search form').submit();$('#modal_window').foundation('reveal','close')"}
        format.json { render :show, status: :created, location: @approve }
      else
        format.js { render js: "alert('#{@approve.errors.full_messages.join(';')}')"}
        format.html do
          drop_page_title(@poly_params.title)
          drop_breadcrumb("我的考勤",home_users_path)
          drop_breadcrumb

          # @approveable = Assault or Episode
          if @poly_params.class_name == "Assault".freeze
            @assault = @approveable
            #@approveable.build_approve
          else
            @episode = @approveable
            @approves = @approveable.approves.to_a
            #@approveable.approves.new
          end

          flash.now[:alert] = @approve.errors.full_messages.join(" ")
          render "#{@poly_params.class_name.tableize}/show"
        end
        format.json { render json: @approve.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  #审批假单
  def approve_episode
    state = 3
    @poly_params.title = '假期审批'
    @poly_params.back_path = episode_path(@task);
    #只做经理，总监，副总确认
    #非驳回请求，如果请假天数大于3天，需要总监再次确认，如果大于等于5天，要求副总进行确认
    if @approveable.sum_total_day > 3 && @approve.state != 2
      leader_user = current_user.leader_user
      #如果请假天数大于5天
      if current_user.title.to_i > 300  #确认人员为经理,则要求总监再作确认
        _task = Task.create(@task.type,leader_user.id,leader_user_id: leader_user.id,date: @task.date,mid: @task.mid)
        Usermailer.episode_approve(_task.task_name).deliver_later
      elsif current_user.title.to_i > 200 #确认人员为总监,且请假天数大于等于5天，则给副总发送确认邮件
        if  @approveable.sum_total_day >= 5
          _task = Task.create(@task.type,leader_user.id,leader_user_id: leader_user.id,date: @task.date,mid: @task.mid)
          Usermailer.episode_approve(_task.task_name).deliver_later
        else
          state = @approve.state
        end
      else #副总
        state = @approve.state
      end
    else #小于三天的假期直接更新状态为审核状态
      state = @approve.state
    end
    state
  end

  #审批突击申请单,副总直接审批
  def approve_assault
    @poly_params.title = '突击申请审批'
    @poly_params.back_path = assault_path(@task);
    @approve.state
  end

  public
  # PATCH/PUT /approves/1
  # PATCH/PUT /approves/1.json
  def update
    respond_to do |format|
      if @approve.update(approve_params)
        format.html { redirect_to @approve, notice: 'Approve was successfully updated.' }
        format.json { render :show, status: :ok, location: @approve }
      else
        format.html { render :edit }
        format.json { render json: @approve.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /approves/1
  # DELETE /approves/1.json
  def destroy
    @approve.destroy
    respond_to do |format|
      format.html { redirect_to approves_url, notice: 'Approve was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_approve
      @approve = Approve.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def approve_params
      params.require(:approve).permit(:user_id, :user_name, :state, :des,:approveable_id, :approveable_type)
    end
end
