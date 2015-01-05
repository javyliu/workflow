class SpecDaysController < ApplicationController
  before_action :set_spec_day, only: [:show, :edit, :update, :destroy]

  # GET /spec_days
  # GET /spec_days.json
  def index
    @spec_days = SpecDay.all
  end

  # GET /spec_days/1
  # GET /spec_days/1.json
  def show
  end

  # GET /spec_days/new
  def new
    @spec_day = SpecDay.new
  end

  # GET /spec_days/1/edit
  def edit
  end

  # POST /spec_days
  # POST /spec_days.json
  def create
    @spec_day = SpecDay.new(spec_day_params)

    respond_to do |format|
      if @spec_day.save
        format.html { redirect_to @spec_day, notice: 'Spec day was successfully created.' }
        format.json { render :show, status: :created, location: @spec_day }
      else
        format.html { render :new }
        format.json { render json: @spec_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /spec_days/1
  # PATCH/PUT /spec_days/1.json
  def update
    respond_to do |format|
      if @spec_day.update(spec_day_params)
        format.html { redirect_to @spec_day, notice: 'Spec day was successfully updated.' }
        format.json { render :show, status: :ok, location: @spec_day }
      else
        format.html { render :edit }
        format.json { render json: @spec_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /spec_days/1
  # DELETE /spec_days/1.json
  def destroy
    @spec_day.destroy
    respond_to do |format|
      format.html { redirect_to spec_days_url, notice: 'Spec day was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_spec_day
      @spec_day = SpecDay.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def spec_day_params
      params.require(:spec_day).permit(:sdate, :is_workday, :comment)
    end
end
