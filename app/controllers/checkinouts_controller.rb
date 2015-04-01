class CheckinoutsController < ApplicationController
  #before_action :set_checkinout, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource param_method: :checkinout_params

  # GET /checkinouts
  # GET /checkinouts.json
  def index
    drop_breadcrumb("我的考勤",home_users_path)
    drop_page_title("我的的签到记录")
    drop_breadcrumb
    @checkinouts = @checkinouts.page(params[:page]).order("id desc").decorate
  end

  def list
    drop_breadcrumb("我的考勤",home_users_path)
    drop_page_title("部门签到记录")
    drop_breadcrumb

    params.permit!
    con_hash,ary_con = construct_condition(:checkinout,gt:[:rec_date],lt:[:rec_date])

    _uids = nil
    if params[:user].present?
      con_hash1,like_con = construct_condition(:user,like_ary: [:user_name])
      _uids = User.where(con_hash1).where(like_con).pluck(:uid) if con_hash1 || like_con
    end

    @checkinouts = @checkinouts.where(con_hash).where(ary_con).page(params[:page]).order("id desc")
    @checkinouts = @checkinouts.where(user_id: _uids) if _uids.present?

    respond_to do |format|
      format.html { @checkinouts = @checkinouts.includes(user: [:dept]).decorate }
      format.js {render partial: "items",object: @checkinouts.includes(user: [:dept]).decorate, content_type: Mime::HTML}
    end
  end

  # GET /checkinouts/1
  # GET /checkinouts/1.json
  def show
  end

  # GET /checkinouts/new
  def new
    @checkinout = Checkinout.new
  end

  # GET /checkinouts/1/edit
  def edit
  end

  # POST /checkinouts
  # POST /checkinouts.json
  def create
    @checkinout = Checkinout.new(checkinout_params)

    respond_to do |format|
      if @checkinout.save
        format.html { redirect_to @checkinout, notice: 'Checkinout was successfully created.' }
        format.json { render :show, status: :created, location: @checkinout }
      else
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
