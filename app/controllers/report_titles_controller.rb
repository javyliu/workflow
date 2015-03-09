class ReportTitlesController < ApplicationController
  #before_action :set_report_title, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /report_titles
  # GET /report_titles.json
  def index
    @attend_rule = AttendRule.find(params[:attend_rule_id])
    drop_breadcrumb("考勤规则管理",attend_rules_path)
    drop_page_title("#{@attend_rule.description}规则表头管理")
    drop_breadcrumb
    @report_titles = ReportTitle.where(id: @attend_rule.title_ids)
  end

  # GET /report_titles/1
  # GET /report_titles/1.json
  def show
  end

  # GET /report_titles/new
  def new
    @report_title = ReportTitle.new
  end

  # GET /report_titles/1/edit
  def edit
    drop_page_title("编辑表头")
    drop_breadcrumb
  end

  # POST /report_titles
  # POST /report_titles.json
  def create
    @report_title = ReportTitle.new(report_title_params)

    respond_to do |format|
      if @report_title.save
        format.html { redirect_to report_titles_path, notice: '操作成功！' }
        format.json { render :show, status: :created, location: @report_title }
      else
        format.html { render :new }
        format.json { render json: @report_title.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /report_titles/1
  # PATCH/PUT /report_titles/1.json
  def update
    respond_to do |format|
      if @report_title.update(report_title_params)
        format.html { redirect_to @report_title, notice: 'Report title was successfully updated.' }
        format.json { render :show, status: :ok, location: @report_title }
      else
        format.html { render :edit }
        format.json { render json: @report_title.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /report_titles/1
  # DELETE /report_titles/1.json
  def destroy
    @report_title.destroy
    respond_to do |format|
      format.html { redirect_to report_titles_url, notice: 'Report title was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report_title
      @report_title = ReportTitle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_title_params
      params.require(:report_title).permit(:name, :des, :ord)
    end
end
