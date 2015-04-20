class AttendRulesController < ApplicationController
  #before_action :set_attend_rule, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /attend_rules
  # GET /attend_rules.json
  def index
    drop_page_title("考勤规则")
    drop_breadcrumb
    @attend_rules = AttendRule.all.decorate
  end

  # GET /attend_rules/1
  # GET /attend_rules/1.json
  def show
  end

  # GET /attend_rules/new
  def new
    @attend_rule = AttendRule.new
  end

  # GET /attend_rules/1/edit
  def edit
    drop_breadcrumb("考勤规则",attend_rules_path)
    drop_page_title("规则编辑")
    drop_breadcrumb
  end

  # POST /attend_rules
  # POST /attend_rules.json
  def create
    @attend_rule = AttendRule.new(attend_rule_params)

    respond_to do |format|
      if @attend_rule.save
        format.html { redirect_to @attend_rule, notice: 'Attend rule was successfully created.' }
        format.json { render :show, status: :created, location: @attend_rule }
      else
        format.html { render :new }
        format.json { render json: @attend_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attend_rules/1
  # PATCH/PUT /attend_rules/1.json
  def update
    respond_to do |format|
      if @attend_rule.update(attend_rule_params.tap{|t|Rails.logger.info("-------#{t.inspect}")})
        flash[:notice] = "操作成功"
        format.html { redirect_to :back }
        format.json { render :show, status: :ok, location: @attend_rule }
      else
        format.html { render :edit }
        format.json { render json: @attend_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attend_rules/1
  # DELETE /attend_rules/1.json
  def destroy
    @attend_rule.destroy
    respond_to do |format|
      format.html { redirect_to attend_rules_url, notice: 'Attend rule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attend_rule
      @attend_rule = AttendRule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attend_rule_params
      params.require(:attend_rule).permit(:name, :description,:min_unit,:time_range, title_ids: [])
    end
end
