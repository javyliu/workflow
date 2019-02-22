class EmSerCatesController < ApplicationController
  #before_action :set_em_ser_cate, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /em_ser_cates
  # GET /em_ser_cates.json
  def index
    drop_page_title("员工服务类别管理")
    drop_breadcrumb
    @em_ser_cates = EmSerCate.cache_all
  end

  # GET /em_ser_cates/1
  # GET /em_ser_cates/1.json
  def show
  end

  # GET /em_ser_cates/new
  def new
    drop_breadcrumb("员工服务类别管理",em_ser_cates_path)
    drop_page_title("新增类别")
    drop_breadcrumb
  end

  # GET /em_ser_cates/1/edit
  def edit
    drop_breadcrumb("员工服务类别管理",em_ser_cates_path)
    drop_page_title("编辑服务类别")
    drop_breadcrumb
  end

  # POST /em_ser_cates
  # POST /em_ser_cates.json
  def create
    @em_ser_cate = EmSerCate.new(em_ser_cate_params)

    respond_to do |format|
      if @em_ser_cate.save
        format.html { redirect_to em_ser_cates_path, notice: '员工服务类别创建成功.' }
        format.json { render :show, status: :created, location: @em_ser_cate }
      else
        drop_breadcrumb("员工服务类别管理",em_ser_cates_path)
        drop_page_title("新增类别")
        drop_breadcrumb
        flash.now[:alert] = "操作失败 #{@em_ser_cate.errors.full_messages}"
        format.html { render :new }
        format.json { render json: @em_ser_cate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /em_ser_cates/1
  # PATCH/PUT /em_ser_cates/1.json
  def update
    respond_to do |format|
      if @em_ser_cate.update(em_ser_cate_params)
        format.html { redirect_to em_ser_cates_path, notice: '操作成功' }
        format.json { render :show, status: :ok, location: @em_ser_cate }
      else
        drop_breadcrumb("员工服务类别管理",em_ser_cates_path)
        drop_page_title("编辑服务类别")
        drop_breadcrumb
        flash.now[:alert] = "操作失败 #{@em_ser_cate.errors.full_messages}"
        format.html { render :edit }
        format.json { render json: @em_ser_cate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /em_ser_cates/1
  # DELETE /em_ser_cates/1.json
  def destroy
    @em_ser_cate.destroy
    respond_to do |format|
      format.html { redirect_to em_ser_cates_url, notice: '操作成功.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_em_ser_cate
      @em_ser_cate = EmSerCate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def em_ser_cate_params
      params.require(:em_ser_cate).permit(:name)
    end
end
