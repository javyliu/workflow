class CheckinoutsController < ApplicationController
  #before_action :set_checkinout, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource param_method: :checkinout_params
  skip_load_resource only: [:create]

  # GET /checkinouts
  # GET /checkinouts.json
  def index
    drop_breadcrumb("我的考勤",home_users_path)
    drop_page_title("我的的签到记录")
    drop_breadcrumb
    params.permit!
    con_hash,ary_con = construct_condition(:checkinout,gt:[:rec_date],lt:[:rec_date])

    @checkinouts = @checkinouts.rewhere(user_id: current_user.id).where(con_hash).where(ary_con).page(params[:page]).order("rec_date desc").decorate
    respond_to do |format|
      format.html {  }
      format.js {render partial: "checkinout_items",object: @checkinouts, content_type: Mime::HTML}
    end
  end

  def list
    #@checkinouts = @checkinouts.select("a.*,GROUP_CONCAT(b.id,'!!',b.description separator '<br>') description,count(a.rec_date) count_journals").joins('a left join journals b on a.user_id = b.user_id and a.rec_date = b.update_date').group('a.id').order('a.id')
    #Rails.logger.debug {@checkinouts.to_sql}
    #用于通过部门查找用户，此时不应该括括直属部门，因为直属管理的部门人员已在resource文件中作为条件做了限定
    if can?(:view,Department) && (depts = current_user.role_depts(include_mine: false).presence) && !User.is_all_dept?(depts)
      @checkinouts = @checkinouts.rewhere(user_id: ( User.where(dept_code: depts).pluck(:uid) + Array.wrap(@checkinouts.where_values_hash["user_id"])))
    end

    params.permit!
    con_hash,ary_con = construct_condition(:checkinout,gt:[:rec_date],lt:[:rec_date])


    _uids = nil
    if params[:user].present?
      con_hash1,like_con = construct_condition(:user,like_ary: [:user_name],left_like:[:dept_code])
      _uids = User.not_expired.where(con_hash1).where(like_con).pluck(:uid) if con_hash1 || like_con
    end

    @checkinouts = @checkinouts.where(con_hash).where(ary_con).page(params[:page])
    @checkinouts = @checkinouts.where(user_id: _uids) if _uids.present?

    @checkinouts = @checkinouts.select("checkinouts.*,GROUP_CONCAT(journals.id,'!!',journals.description separator '<br>') description,count(journals.id) count_journals").joins('left join journals on checkinouts.user_id = journals.user_id and checkinouts.rec_date = journals.update_date').group('checkinouts.id').order('checkinouts.id desc')
    @checkinouts = @checkinouts.preload(user: [:dept]).decorate

    #@checkinouts.except(:select,:joins,:limit,:order,:offset,:group).total_count
    @checkinouts.set_total_count{|obj| obj.except(:joins,:select,:limit,:order,:offset,:group).count}
    #@checkinouts.instance_variable_set(:@total_count,

    respond_to do |format|
      format.html do
        drop_breadcrumb("我的考勤",home_users_path)
        drop_page_title("部门签到记录")
        drop_breadcrumb
      end
      format.js do
        render partial: "items",object: @checkinouts, content_type: Mime::HTML
      end
    end
  end

  # GET /checkinouts/1
  # GET /checkinouts/1.json
  def show
  end

  # GET /checkinouts/new
  def new
    #@checkinout = Checkinout.new
    drop_breadcrumb("我的考勤",home_users_path)
    drop_page_title("考勤数据同步")
    drop_breadcrumb
  end

  # GET /checkinouts/1/edit
  def edit
  end

  # POST /checkinouts
  # POST /checkinouts.json
  def create
    #@checkinout = Checkinout.new(checkinout_params)

    respond_to do |format|
      if params[:from].present? && params[:to].present?
        SysKaoqingDataJob.perform_later(from: params[:from],to: params[:to],unames: params[:uname])
        format.html { redirect_to new_checkinout_path , notice: "#{params[:from]}至#{params[:to]} 的考勤同步任务创建完成,稍后完成同步!" }
        format.json { render :show, status: :created, location: @checkinout }
      else
        @checkinout = Checkinout.new
        drop_breadcrumb("我的考勤",home_users_path)
        drop_page_title("考勤数据同步")
        drop_breadcrumb
        flash.now[:alert] = "任务创建失败！请输入正确的日期格式"
        format.html { render :new }
        format.json { render json: @checkinout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checkinouts/1
  # PATCH/PUT /checkinouts/1.json
  def update
    respond_to do |format|
      if @checkinout.update(checkinout_params)
        format.html { redirect_to @checkinout, notice: 'Checkinout was successfully updated.' }
        format.json { render :show, status: :ok, location: @checkinout }
      else
        format.html { render :edit }
        format.json { render json: @checkinout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checkinouts/1
  # DELETE /checkinouts/1.json
  def destroy
    @checkinout.destroy
    respond_to do |format|
      format.html { redirect_to checkinouts_url, notice: 'Checkinout was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checkinout
      @checkinout = Checkinout.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def checkinout_params
      params.permit! #.require(:checkinout).permit(:user_id, :rec_date, :checkin, :checkout, :ref_time)
    end
end
