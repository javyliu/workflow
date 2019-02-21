class EmServicesController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: [:index,:show]

  # GET /em_services
  # GET /em_services.json
  def index
    drop_page_title("员工服务")
    drop_breadcrumb
    @em_services = EmService.page(params[:page])
  end

  #管理员专用
  def list
    drop_page_title("员工服务管理")
    drop_breadcrumb
    @em_services = EmService.page(params[:page])
  end
  # GET /em_services/1
  # GET /em_services/1.json
  def show
  end

  # GET /em_services/new
  def new
    drop_breadcrumb("员工服务管理",em_services_path)
    drop_page_title("新增")
    drop_breadcrumb
  end

  # GET /em_services/1/edit
  def edit
    drop_breadcrumb("员工服务管理",em_services_path)
    drop_page_title("编辑")
    drop_breadcrumb
  end

  # POST /em_services
  # POST /em_services.json
  def create
    @em_service = EmService.new(em_service_params)

    respond_to do |format|
      if @em_service.save
        format.html { redirect_to list_em_services_path, notice: '创建成功.' }
        format.json { render :show, status: :created, location: @em_service }
      else
        drop_breadcrumb("员工服务管理",em_services_path)
        drop_page_title("新增")
        drop_breadcrumb
        flash.now[:alert] = "操作失败 #{@em_service.errors.full_messages}"
        format.html { render :new }
        format.json { render json: @em_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /em_services/1
  # PATCH/PUT /em_services/1.json
  def update
    respond_to do |format|
      if @em_service.update(em_service_params)
        format.html { redirect_to list_em_services_path, notice: '更新成功.' }
        format.json { render :show, status: :ok, location: @em_service }
      else
        drop_breadcrumb("员工服务管理",em_services_path)
        drop_page_title("编辑")
        drop_breadcrumb
        flash.now[:alert] = "操作失败 #{@em_service.errors.full_messages}"
        format.html { render :edit }
        format.json { render json: @em_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /em_services/1
  # DELETE /em_services/1.json
  def destroy
    @em_service.destroy
    respond_to do |format|
      format.html { redirect_to em_services_url, notice: 'Em service was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_em_service
      @em_service = EmService.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def em_service_params
      params.require(:em_service).permit(:title, :content)
    end
end
