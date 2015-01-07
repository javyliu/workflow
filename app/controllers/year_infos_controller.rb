class YearInfosController < ApplicationController
  before_action :set_year_info, only: [:show, :edit, :update, :destroy]

  # GET /year_infos
  # GET /year_infos.json
  def index
    @year_infos = YearInfo.all
  end

  # GET /year_infos/1
  # GET /year_infos/1.json
  def show
  end

  # GET /year_infos/new
  def new
    @year_info = YearInfo.new
  end

  # GET /year_infos/1/edit
  def edit
  end

  # POST /year_infos
  # POST /year_infos.json
  def create
    @year_info = YearInfo.new(year_info_params)

    respond_to do |format|
      if @year_info.save
        format.html { redirect_to @year_info, notice: 'Year info was successfully created.' }
        format.json { render :show, status: :created, location: @year_info }
      else
        format.html { render :new }
        format.json { render json: @year_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /year_infos/1
  # PATCH/PUT /year_infos/1.json
  def update
    respond_to do |format|
      if @year_info.update(year_info_params)
        format.html { redirect_to @year_info, notice: 'Year info was successfully updated.' }
        format.json { render :show, status: :ok, location: @year_info }
      else
        format.html { render :edit }
        format.json { render json: @year_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /year_infos/1
  # DELETE /year_infos/1.json
  def destroy
    @year_info.destroy
    respond_to do |format|
      format.html { redirect_to year_infos_url, notice: 'Year info was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_year_info
      @year_info = YearInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def year_info_params
      params.require(:year_info).permit(:year, :user_id, :year_holiday, :sick_leave, :affair_leave, :switch_leave, :ab_point)
    end
end
