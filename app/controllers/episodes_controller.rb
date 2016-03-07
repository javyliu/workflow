class EpisodesController < ApplicationController
  #before_action :set_episode, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:show]

  # GET /episodes
  # GET /episodes.json
  def index
    drop_page_title("我的申请")
    drop_breadcrumb("我的考勤",home_users_path)
    drop_breadcrumb
    @episodes = @episodes.rewhere(user_id: current_user.id).where(parent_id: 0).order("id desc").page(params[:page]).includes(:holiday).decorate
  end

  def list
    drop_page_title("部门申请")
    drop_breadcrumb("我的考勤",home_users_path)
    drop_breadcrumb
    @episodes = @episodes.order("id desc")

    #如果角色资源中设置了查看部门并且非全部部门，则会重新设置user_id查询参数，
    #目的是为了减少查询语句中的长度，提升性能
    if (depts = current_user.role_depts(include_mine: false).presence) && !User.is_all_dept?(depts)
      #Rails.logger.debug {depts.inspect}
      @episodes = @episodes.rewhere(user_id: ( User.where(dept_code: depts).pluck(:uid) + Array.wrap(@episodes.where_values_hash["user_id"])))
    end

    respond_to do |format|
      format.html do
        @episodes = @episodes.where("parent_id=0 and start_date >= ? ",OaConfig.setting(:end_year_time)).page(params[:page]).includes(:holiday,user:[:dept]).decorate
      end
      format.js do
        params.permit!
        con_hash,like_hash = construct_condition(:user,like_ary: [:user_name,:email],left_like: [:email,:dept_code])
        #Rails.logger.info con_hash.inspect
        #Rails.logger.info like_hash.inspect
        _user_ids = User.where(con_hash).where(like_hash).pluck(:uid) if con_hash || like_hash

        con_hash1,array_con = construct_condition(:episode,gt: [:start_date],lt: [:end_date])

        #Rails.logger.info array_con.inspect
        @episodes = @episodes.where(parent_id: 0)
        @episodes = @episodes.where(user_id: _user_ids) if _user_ids
        if params[:episode] && params[:episode][:start_date].blank?
          @episodes = @episodes.where("start_date >= ? ",OaConfig.setting(:end_year_time))
        end
        @episodes = @episodes.page(params[:page]).where(con_hash1).where(array_con).includes(:holiday,user:[:dept]).decorate

        render partial: "items",object: @episodes, content_type: Mime::HTML
      end

      format.xls do
        params.permit!
        con_hash,like_hash = construct_condition(:user,like_ary: [:user_name,:email])
        _user_ids = User.where(con_hash).where(like_hash).pluck(:uid) if con_hash || like_hash
        con_hash1,array_con = construct_condition(:episode,gt: [:start_date],lt: [:end_date])
        @episodes = @episodes.where(user_id: _user_ids) if _user_ids
        @episodes = @episodes.where(con_hash1).where(array_con)

        _select = "user_id,holiday_id,start_date,end_date,total_time,state,comment,episodes.created_at"
        @episodes = @episodes.select(_select).includes(user: [:dept])#.joins(" inner join users on user_id=uid inner join departments on dept_code = code")
        _holidays = Holiday.all.pluck(:id,:name)
        cols = "user_id,user_name,dept_name,holiday_id,start_date,end_date,total_time,unit,state,comment,created_at".split(",")
        xsl_file = @episodes.to_csv(select: "用户编号,姓名,部门,假别,开始时间,结束时间,时长,单位,审批状态,说明,创建时间") do |item,_|
          _attrs = item.attributes
          _attrs["created_at"] = item.created_at.try(:strftime,"%F %T")
          _attrs["user_name"] = item.user.try(:user_name)
          _attrs["dept_name"] = item.user.try(:dept).try(:name)
          _attrs["unit"] = Holiday.unit(item.holiday_id)
          _attrs["start_date"] = item.start_date.try(:strftime,"%F %T")
          _attrs["end_date"] = item.end_date.try(:strftime,"%F %T")
          _attrs["state"] = Episode::State.rassoc(item.state).first
          _attrs["holiday_id"] = _holidays.assoc(item.holiday_id).last
          _attrs.values_at(*cols)#.tap{|t|Rails.logger.info(t.inspect)}
        end
        #xsl_file
        #send_data xsl_file
        send_data xsl_file,disposition: 'attachment', filename: "episodes_data_#{Date.today.to_s(:number)}.xls"
      end


    end
  end
  # GET /episodes/1 or
  # GET /episodes/F002:1416:2014-10-10:10
  # GET /episodes/1.json
  def show
    if /^\d+$/ =~ params[:task]
      @episode = Episode.find_by(id:params[:task]).try(:parent)
      raise CanCan::AccessDenied.new("该申请不存在！",home_users_path ) unless @episode
      @task = Task.new("F002",@episode.user.leader_user.id,date:@episode.created_at.to_date.to_s,mid:@episode.id)
    else
      @task =  Task.init_from_subject(params[:task])
      @episode = Episode.find_by(id:@task.mid)
      unless @episode
        @task.remove(all: true)
        raise CanCan::AccessDenied.new("该申请不存在！",home_users_path )
      end
    end

    unless @episode.user
      @task.remove(all: true)
      raise CanCan::AccessDenied.new("该员工已离职！",home_users_path )
    end
    #跨级审批时会报错，除非加上审批权限
    #authorize!(:show,@episode)
    @approves = @episode.approves.to_a
    #Rails.logger.info @approves.inspect
    #如果当前用户有审批任务
    if current_user.pending_tasks.include?(@task.to_s)
      @new_approve = @episode.approves.new
    end

    respond_to do |format|
      format.html do
        drop_page_title("申请审批")
        drop_breadcrumb("我的考勤",home_users_path)
        drop_breadcrumb("部门申请",list_episodes_path)
        drop_breadcrumb
      end
      format.js do
        expires_now
        render template: 'episodes/show',content_type: Mime::HTML
      end
    end

  end

  # GET /episodes/new
  def new
    #if params[:holiday_id].blank? || (@holiday = Holiday.find_by(id: params[:holiday_id])).nil?
      #flash[:alert] = "请选择类别"
      #redirect_to action: :index and return
    #end


    drop_page_title("假期申请")
    drop_breadcrumb("我的申请",episodes_path)
    drop_breadcrumb

    #@episode.start_date =  Time.now.beginning_of_day.strftime("%Y-%m-%d %H:%M")
    #@episode.end_date = Time.now.end_of_day.strftime("%Y-%m-%d %H:%M")
    #@episode.holiday = @holiday
    if params[:journal_id].present? && journal = Journal.find_by(id: params[:journal_id])
      @episode.start_date = journal.update_date.beginning_of_day
      @episode.end_date = journal.update_date.end_of_day
    end
    @episode.title = current_user.title
    @episode.holiday_id = params[:holiday_id]
    #@episode.children = [Episode.new]
  end

  # GET /episodes/1/edit
  def edit
    @user = current_user.decorate
    drop_breadcrumb("我的申请",episodes_path)
    drop_page_title("编辑申请")
    drop_breadcrumb
  end

  # POST /episodes
  # POST /episodes.json
  def create
    #@episode = Episode.new(episode_params)
    @episode.user_id = current_user.id

    #@episode.ck_type = Journal::CheckType.detect{|item|item[6] == @episode.holiday_id}.try(:second)

    @episode.children.each do |item|
      item.title = @episode.title
      item.comment = @episode.comment
      item.user_id = current_user.id
    end

    respond_to do |format|
      if @episode.save
        #生成任务
        leader_user = current_user.leader_user

        _task = Task.create("F002",leader_user.id,leader_user_id: leader_user.id,date: @episode.created_at.to_date.to_s,mid: @episode.id)
        Rails.logger.info _task.task_name
        #发送邮件
        Usermailer.episode_approve(_task.task_name).deliver_later

        format.html { redirect_to episodes_path, notice: '提交成功，请等待审批!' }
        format.json { render :show, status: :created, location: @episode }
      else
        drop_page_title("假期申请")
        drop_breadcrumb("我的申请",episodes_path)
        drop_breadcrumb
        flash.now[:alert] = @episode.errors.full_messages.join("\n")
        format.html { render :new }
        format.json { render json: @episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /episodes/1
  # PATCH/PUT /episodes/1.json
  # 正常不应该有更改假单的权限，应该是删除后重新更新，因为如果用户更新了假期的话会出现问题
  def update
    @episode.assign_attributes(episode_params)
    @episode.children.each do |item|
      item.title = @episode.title
      item.comment = @episode.comment
    end
    respond_to do |format|
      if @episode.save
        format.html { redirect_to @episode, notice: 'Episode was successfully updated.' }
        format.json { render :show, status: :ok, location: @episode }
      else
        format.html { render :edit }
        format.json { render json: @episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /episodes/1
  # DELETE /episodes/1.json
  def destroy
    @episode.destroy
    respond_to do |format|
      format.html { redirect_to episodes_url, notice: 'Episode was successfully destroyed.' }
      format.json do
        Usermailer.info_msg(@episode.user_id,"申请删除通知","您的#{@episode.holiday.name} #{@episode.total_time} #{Holiday.unit(@episode.holiday_id)}申请已被 #{current_user.user_name} 删除。".tap{|t|Rails.logger.info(t)}).deliver_later
        head :no_content
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_episode
      @episode = Episode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def episode_params
      params.require(:episode).permit(:user_id,  :comment, :approved_by, :approved_time,:title,:total_time,:holiday_id, :start_date, :end_date,:_destroy,children_attributes: [:total_time,:holiday_id, :start_date, :end_date,:_destroy,:id])
    end
end
