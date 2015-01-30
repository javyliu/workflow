class CheckinoutsController < ApplicationController
  #before_action :set_checkinout, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource param_method: :checkinout_params

  # GET /checkinouts
  # GET /checkinouts.json
  def index
    drop_page_title("签到记录")
    drop_breadcrumb

    if params[:only] == "me"
      @checkinouts = Checkinout.all
      con_hash = {user_id: current_user.id}
    else
      params.permit!
      con_hash,_ = construct_condition(:checkinout)
    end

    if params[:user].present?
      con_hash.merge!("users.dept_code" => params[:user][:dept_code])
    end

    @checkinouts = @checkinouts.select("checkinouts.*,users.user_name,departments.name dept_name").joins(user: [:dept]).where(con_hash).order("id desc").page(params[:page])#.includes(user: [:dept])

    respond_to do |format|
      format.html { @checkinouts = @checkinouts.decorate }
      format.js {render partial: "items",object: @checkinouts.decorate, content_type: Mime::HTML}
      format.xls do
        select_columns = "checkinouts.id,users.user_name,departments.name dept_name,checkinouts.user_id,checkinouts.checkin,checkinouts.checkout"
        @checkinouts = Checkinout.accessible_by(current_ability).where(con_hash).joins(user: [:dept]).select(select_columns)
        send_data @checkinouts.to_csv(select: select_columns)
      end
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
      params.require(:checkinout).permit(:user_id, :rec_date, :checkin, :checkout, :ref_time)
    end
end