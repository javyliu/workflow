class DepartmentsController < ApplicationController
  #before_action :set_department, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /departments
  # GET /departments.json
  def index
    drop_page_title("部门管理")
    drop_breadcrumb
    params.permit!
    con_hash,_ = construct_condition(:department)
    @departments = @departments.where(con_hash).page(params[:page]).includes(:attend_rule,:leader_user)
    respond_to do |format|
      format.html { @departments = @departments.decorate }
      format.js {render partial: "items",object: @departments.decorate, content_type: Mime::HTML}
      format.xls {send_data @departments.unscope(:limit,:offset).to_csv(col_sep: "\t")}
    end
  end

  # GET /departments/1
  # GET /departments/1.json
  def show
    drop_breadcrumb("部门管理",departments_path)
    drop_page_title("部门详情")
    drop_breadcrumb
  end

  # GET /departments/new
  def new
    @department = Department.new
  end

  # GET /departments/1/edit
  def edit
    drop_breadcrumb("部门列表",departments_path)
    drop_page_title("部门编辑")
    drop_breadcrumb
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = Department.new(department_params)

    respond_to do |format|
      if @department.save
        format.html { redirect_to @department, notice: "操作成功"}
        format.json { render :show, status: :created, location: @department }
      else
        format.html { render :new }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to @department, notice: 'Department was successfully updated.' }
        format.json { render :show, status: :ok, location: @department }
      else
        format.html { render :edit }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    @department.destroy
    respond_to do |format|
      format.html { redirect_to departments_url, notice: 'Department was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @department = Department.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit(:attend_rule_id,:mgr_code)
    end
end
