class EpisodesController < ApplicationController
  #before_action :set_episode, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /episodes
  # GET /episodes.json
  def index
    drop_page_title("我的假条")
    drop_breadcrumb("我的考勤",home_users_path)
    drop_breadcrumb
    @episodes = @episodes.page(params[:page]).includes(:holiday,:user).decorate
  end

  def list
    drop_page_title("部门假条")
    drop_breadcrumb("我的考勤",home_users_path)
    drop_breadcrumb
    @episodes = @episodes.page(params[:page]).includes(:holiday,:user).decorate
    render template: "episodes/index"

  end
  # GET /episodes/1
  # GET /episodes/1.json
  def show
  end

  # GET /episodes/new
  def new
    if params[:holiday_id].blank? || (@holiday = Holiday.find_by(id: params[:holiday_id])).nil?
      flash[:alert] = "请选择假期类别"
      redirect_to action: :index and return
    end

    drop_page_title("假期申请")
    drop_breadcrumb("我的假条",episodes_path)
    drop_breadcrumb

    @episode.start_date =  Time.now.beginning_of_day.strftime("%Y-%m-%d %H:%M")
    @episode.end_date = Time.now.end_of_day.strftime("%Y-%m-%d %H:%M")
    @episode.holiday = @holiday
  end

  # GET /episodes/1/edit
  def edit
  end

  # POST /episodes
  # POST /episodes.json
  def create
    @episode = Episode.new(episode_params)
    @episode.user_id = current_user.id
    respond_to do |format|
      if @episode.save
        format.html { redirect_to @episode, notice: '申请成功，请等待审批!' }
        format.json { render :show, status: :created, location: @episode }
      else
        format.html { render :new }
        format.json { render json: @episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /episodes/1
  # PATCH/PUT /episodes/1.json
  def update
    respond_to do |format|
      if @episode.update(episode_params)
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
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_episode
      @episode = Episode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def episode_params
      params.require(:episode).permit(:user_id, :holiday_id, :start_date, :end_date, :comment, :approved_by, :approved_time)
    end
end
