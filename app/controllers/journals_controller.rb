class JournalsController < ApplicationController
  before_action :set_journal, only: [:show, :edit, :destroy]

  # GET /journals
  # GET /journals.json
  def index
    @journals = Journal.all
  end

  # GET /journals/1
  # GET /journals/1.json
  def show
  end

  # GET /journals/new
  def new
    @journal = Journal.new
  end

  # GET /journals/1/edit
  def edit
  end

  # POST /journals
  # POST /journals.json
  def create
    @journal = Journal.new(journal_params)

    respond_to do |format|
      if @journal.save
        format.html { redirect_to @journal, notice: 'Journal was successfully created.' }
        format.json { render :show, status: :created, location: @journal }
      else
        format.html { render :new }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /journals/1
  # PATCH/PUT /journals/1.json
  def update
    msg = nil
    #用于考勤确认
    if params[:date].present? && params[:user_id]

      @task = Task.new("F001",current_user.id,date: params[:date])
      is_mine = @task.leader_user_id == current_user.id
      #if (current_user.roles & ["department_manager","admin"]).blank? && !is_mine
      if !is_mine
        raise CanCan::AccessDenied.new("未授权", home_users_path,params[:task])
      end

      @journal = Journal.find_or_initialize_by(user_id: params[:user_id],update_date: params[:date])
      @journal.dval = 0

      params[:journal].each do |k,v|
        cktype = Journal::CheckType.assoc(k)
        raise "类型不存在 #{k}" unless cktype
        @journal.check_type = cktype.second
        if @journal.check_type == 10
          @journal.description = "特批：#{v}"
        else
          @journal.dval = v.to_f * cktype.last
        end
      end

      if @journal.save
        @msg = params[:journal]
      else
        msg = @journal.errors
      end
    elsif params[:id]
      set_journal
      unless @journal.update(journal_params)
        msg = @journal.errors
      end
    else
      msg = {msg:"出错了！"}
    end
    respond_to do |format|
      if msg.blank?
        format.html { redirect_to @journal, notice: 'Journal was successfully updated.' }
        format.json do
          if @msg
            render json: @msg
          else
            render :show, status: :ok, location: @journal
          end
        end
      else
        format.html { render :edit }
        format.json { render json: msg, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /journals/1
  # DELETE /journals/1.json
  def destroy
    @journal.destroy
    respond_to do |format|
      format.html { redirect_to journals_url, notice: 'Journal was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_journal
    @journal = Journal.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def journal_params
    params.require(:journal).permit(:user_id, :update_date, :check_type, :description, :dval)
  end
end