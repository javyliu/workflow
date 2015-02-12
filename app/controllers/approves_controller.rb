class ApprovesController < ApplicationController
  before_action :set_approfe, only: [:show, :edit, :update, :destroy]

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
    @approfe = Approve.new
  end

  # GET /approves/1/edit
  def edit
  end

  # POST /approves
  # POST /approves.json
  def create
    @approfe = Approve.new(approfe_params)

    respond_to do |format|
      if @approfe.save
        format.html { redirect_to @approfe, notice: 'Approve was successfully created.' }
        format.json { render :show, status: :created, location: @approfe }
      else
        format.html { render :new }
        format.json { render json: @approfe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /approves/1
  # PATCH/PUT /approves/1.json
  def update
    respond_to do |format|
      if @approfe.update(approfe_params)
        format.html { redirect_to @approfe, notice: 'Approve was successfully updated.' }
        format.json { render :show, status: :ok, location: @approfe }
      else
        format.html { render :edit }
        format.json { render json: @approfe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /approves/1
  # DELETE /approves/1.json
  def destroy
    @approfe.destroy
    respond_to do |format|
      format.html { redirect_to approves_url, notice: 'Approve was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_approfe
      @approfe = Approve.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def approfe_params
      params.require(:approfe).permit(:user_id, :user_name, :state, :des, :episode_id)
    end
end
