class OaConfigsController < ApplicationController
  #before_action :set_oa_config, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /oa_configs
  # GET /oa_configs.json
  def index
    drop_page_title("系统配置")
    drop_breadcrumb
    @oa_configs = OaConfig.all
  end

  # GET /oa_configs/1
  # GET /oa_configs/1.json
  def show
  end

  # GET /oa_configs/new
  def new
    @oa_config = OaConfig.new
  end

  # GET /oa_configs/1/edit
  def edit
    drop_page_title("编辑系统配置")
    drop_breadcrumb
  end

  # POST /oa_configs
  # POST /oa_configs.json
  def create
    @oa_config = OaConfig.new(oa_config_params)

    respond_to do |format|
      if @oa_config.save
        format.html { redirect_to @oa_config, notice: 'Oa config was successfully created.' }
        format.json { render :show, status: :created, location: @oa_config }
      else
        format.html { render :new }
        format.json { render json: @oa_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /oa_configs/1
  # PATCH/PUT /oa_configs/1.json
  def update
    respond_to do |format|
      if @oa_config.update(oa_config_params)
        format.html { redirect_to oa_configs_path, notice: '操作成功' }
        format.json { render :show, status: :ok, location: @oa_config }
      else
        flash.now[:alert] = @oa_config.errors.full_messages
        format.html { render :edit }
        format.json { render json: @oa_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /oa_configs/1
  # DELETE /oa_configs/1.json
  def destroy
    @oa_config.destroy
    respond_to do |format|
      format.html { redirect_to oa_configs_url, notice: 'Oa config was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_oa_config
      @oa_config = OaConfig.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def oa_config_params
      params.require(:oa_config).permit(:des, :value)
    end
end
