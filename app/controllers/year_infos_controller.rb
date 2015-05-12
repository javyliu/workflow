class YearInfosController < ApplicationController
  #before_action :set_year_info, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]
  # GET /year_infos
  # GET /year_infos.json
  def index
    drop_page_title("基础假期管理")
    drop_breadcrumb
    @year_infos = @year_infos.order("year desc")
    respond_to do |format|
      format.html do
        @year_infos = @year_infos.page(params[:page]).includes(:user)
      end
      format.js do
        params.permit!
        con_hash,like_hash = construct_condition(:user,like_ary: [:user_name,:email])
        _user_ids = User.where(con_hash).where(like_hash).pluck(:uid) if con_hash || like_hash
        @year_infos = @year_infos.where(params[:date]) if params[:date] && params[:date][:year].present?
        @year_infos = @year_infos.where(user_id: _user_ids) if _user_ids
        @year_infos = @year_infos.page(params[:page]).includes(:user)

        render partial: "items",object: @year_infos, content_type: Mime::HTML

      end

      format.xls do
        _select = "year,user_id,user_name,name dept_name,year_holiday,sick_leave,affair_leave,switch_leave,ab_point,null r_year_holiday,null r_sick_leave,null r_affair_leave,null r_switch_leave,null r_ab_point"
        params.permit!
        con_hash,like_hash = construct_condition(:user,like_ary: [:user_name,:email])
        _user_ids = User.where(con_hash).where(like_hash).pluck(:uid) if con_hash || like_hash
        @year_infos = @year_infos.select(_select).joins(" inner join users on user_id = uid inner join departments on dept_code = code")
        @year_infos = @year_infos.where(params[:date]) if params[:date] && params[:date][:year].present?


        @user_year_journals = Journal.where(["update_date > ?",OaConfig.setting(:end_year_time)]).select("id,user_id,check_type,sum(dval) dval").group(:user_id,:check_type)

        if _user_ids
          @year_infos = @year_infos.where(user_id: _user_ids)
          @user_year_journals = @user_year_journals.where(user_id: _user_ids)
        end
        #@user_year_journals = @user_year_journals.to_a

        _start_year = OaConfig.setting(:end_year_time)[/\d+/].to_i
        xsl_file = @year_infos.to_csv(select: _select) do |item,cols|
          _attrs = item.attributes
          _attrs["year_holiday"] = item.year_holiday.to_f/10
          _attrs["sick_leave"] = item.sick_leave.to_f/10
          _attrs["affair_leave"] = item.affair_leave.to_f/10
          _attrs["switch_leave"] = item.switch_leave.to_f/10
          _attrs["ab_point"] = item.ab_point.to_f/10

          #TODO need fix the number type
          if item.year == _start_year
            _attrs["r_year_holiday"] = ( item.year_holiday - year_journal(item.user_id,5)).to_f/10
            _attrs["r_sick_leave"] = (item.sick_leave - year_journal(item.user_id,17)).to_f/10
            _attrs["r_affair_leave"] = ( item.affair_leave - year_journal(item.user_id,11)).to_f/10
            _attrs["r_switch_leave"] =(item.switch_leave + year_journal(item.user_id,8) + year_journal(item.user_id,12)).to_f/10
            _attrs["r_ab_point"] =  (item.ab_point + year_journal(item.user_id,9) + year_journal(item.user_id,21) + year_journal(item.user_id,24)+ year_journal(item.user_id,25)).to_f/10
          end
          _attrs.values_at(*cols)#.tap{|t|Rails.logger.info(t.inspect)}
        end
        #xsl_file
        send_data xsl_file
      end
    end
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
    #@year_info = YearInfo.new(year_info_params)

    msgs = []
    _calcute_date = Date.parse(OaConfig.setting(:end_year_time))
    _year = Date.today.year
    _last_year = _year - 1
    _attrs = case params[:type]
             when "all"
               {year_holiday: 50,sick_leave: OaConfig.setting(:sick_leave_days).to_i * 10,affair_leave: OaConfig.setting(:affair_leave_days).to_i * 10,switch_leave: 0,ab_point: 0}
             when "year_holiday"
               {year_holiday: 50}
             when "sick_leave"
               {sick_leave: OaConfig.setting(:sick_leave_days).to_i * 10}
             when "affair_leave"
               {affair_leave: OaConfig.setting(:affair_leave_days).to_i * 10}
             when "switch_leave"
               {switch_leave: 0}
             when "ab_point"
               {ab_point: 0}
             end


    User.where("email is not null").find_each do |item|

      if _attrs[:year_holiday] #计算年假
        _total_years = (_calcute_date - item.onboard_date).fdiv(365)
        _attrs[:year_holiday] = if _total_years < 1
                                  0
                                elsif _total_years <= 10
                                  50
                                elsif _total_years <= 20
                                  100
                                else
                                  150
                                end

      end
      Rails.logger.info _attrs.inspect
      _year_info = YearInfo.find_or_initialize_by(year: _year,user_id: item.id)
      _year_info.assign_attributes(_attrs)
      _year_info.save!
    end

    respond_to do |format|
      if msgs.blank?
        format.html { redirect_to year_infos_path, success: '操作成功' }
        format.json { render :show, status: :created, location: @year_info }
      else
        format.html { redirect_to :back }
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


    def year_journal(user_id,check_type_id)
      @user_year_journals.detect { |e| e.user_id == user_id && e.check_type == check_type_id }.try(:dval).to_i #.tap{|t|Rails.logger.info("-#{user_id}--#{check_type_id}---#{t}")}
    end
end
