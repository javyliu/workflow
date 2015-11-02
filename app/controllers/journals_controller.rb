class JournalsController < ApplicationController
  #before_action :set_journal, only: [:show, :edit, :destroy]
  load_and_authorize_resource# param_method: :journal_params
  skip_load_resource only: [:new,:create,:update]

  UserData = Struct.new(:dept_name,:user_name,:remain_switch_time,:remain_holiday_year,:remain_sick_salary,:remain_affair_salary,:remain_ab_points,*Journal::CheckType.transpose[0].map(&:intern))
  # GET /journals
  # GET /journals.json
  def index
    drop_breadcrumb("我的考勤",home_users_path)
    drop_page_title("异常考勤记录")
    drop_breadcrumb
    params.permit!
    con_hash,ary_con = construct_condition(:journal,gt:[:update_date],lt:[:update_date])
    @journals = @journals.rewhere(user_id: current_user.id).where(con_hash).where(ary_con).where("check_type = 10 or dval != 0").order("update_date desc,id desc").page(params[:page])
    .select("journals.*,checkin,checkout,episodes.id episode_id,episodes.holiday_id,episodes.state")
    .joins("left join checkinouts on update_date = rec_date and journals.user_id = checkinouts.user_id
    left join episodes on journals.user_id = episodes.user_id and ck_type = check_type and state <> 2 and update_date >= date(start_date) and update_date <= end_date ")

    respond_to do |format|
      format.html {  }
      format.xls do
        response.headers['Content-Disposition'] = 'attachment; filename="社区工作.xls"'
        render template: 'journals/month_kaoqin'
      end
      format.js { render partial: "j_items",object: @journals, content_type: Mime::HTML}
    end
  end

  def list
    drop_breadcrumb("我的考勤",home_users_path)
    drop_page_title("部门审批记录")
    drop_breadcrumb

    @start_time = params[:journal].try(:[],:gt_update_date)
    @end_time = params[:journal].try(:[],:lt_update_date)
      #Rails.logger.debug {@journals.to_sql}
    if (depts = current_user.role_depts(include_mine: false).presence) && !User.is_all_dept?(depts)
      @journals = @journals.rewhere(user_id: ( User.where(dept_code: depts).pluck(:uid) + Array.wrap(@journals.where_values_hash["user_id"])))
    end

    params.permit!
    con_hash,ary_con = construct_condition(:journal,gt:[:update_date],lt:[:update_date])

    @journals = @journals.where("check_type = 10 or dval <> 0").where(con_hash).where(ary_con).order("update_date desc")
    if params[:is_updated]
      @journals.where_values.map do |item|
        item.gsub!(/update_date/,'journals.updated_at') if String === item
        item
      end
      @journals = @journals.where('journals.updated_at <> journals.created_at')
    end

    _uids = nil
    if params[:user].present?
      con_hash1,like_con = construct_condition(:user,like_ary: [:user_name])
      _uids = User.where(con_hash1).where(like_con).pluck(:uid) if con_hash1 || like_con
      @journals = @journals.where(user_id: _uids) if _uids
    end

      #Rails.logger.debug {@journals.to_sql}
    _select = "journals.id,update_date,checkin,checkout,journals.user_id,journals.created_at,journals.updated_at,user_name,check_type,dval,null unit,description,departments.name dept_name,episodes.id episode_id,episodes.holiday_id,episodes.state"

    @html_journals = @journals.select(_select).joins(" left join checkinouts on update_date=rec_date and journals.user_id = checkinouts.user_id
                                                inner join users on uid = journals.user_id
                                                inner join departments on dept_code = code
                                                left join episodes on journals.user_id = episodes.user_id and ck_type = check_type and state <> 2 and update_date >= date(start_date) and update_date <= end_date
                                                ")
    respond_to do |format|
      format.html do
        @html_journals = @html_journals.page(params[:page])
      end
      format.js do
        @html_journals = @html_journals.page(params[:page])
        render partial: "items",object: @html_journals, content_type: Mime::HTML
      end
      format.xlsx do
        response.headers['Content-Disposition'] = "attachment; filename='考勤汇总表.xlsx'"
        _select = "id,group_concat(update_date) comments,user_id,check_type,sum(dval) dval,group_concat(description separator '<br>') description"

        @journals = @journals.select(_select).group("user_id,check_type").includes(user:[:dept,:last_year_info,:year_journals])

        @journals = @journals.group_by(&:user_id).inject([]) do |sum,(_k,v)|
          ud = UserData.new

          user = v.first.user

          #用户已离职
          next sum unless user

          @year_journals = user.year_journals

          ud.dept_name = user.dept.name
          ud.user_name = user.user_name

          base_holiday_info ||= user.last_year_info
          if  base_holiday_info
            #年假
            ud.remain_holiday_year = ( base_holiday_info.year_holiday - year_journal(5) ).to_f/10
            #倒休
            ud.remain_switch_time = (base_holiday_info.switch_leave + year_journal(8) + year_journal(12)).to_f/10
            #带薪病假
            ud.remain_sick_salary = (base_holiday_info.sick_leave - year_journal(17)).to_f/10
            #带薪事假
            ud.remain_affair_salary = ( base_holiday_info.affair_leave - year_journal(11) ).to_f/10
            #ab分
            ud.remain_ab_points = (base_holiday_info.ab_point + year_journal(9) + year_journal(21) + year_journal(24)+ year_journal(25)).to_f/10
          end

          UserData.members.each do |att|
            att = att.to_s
            ck_type = Journal::CheckType.assoc(att)
            next unless ck_type
            journal = v.detect{|item| item.check_type == ck_type[1]}
            next unless journal
            s_unit = ck_type[7]
            if att.start_with?("c_aff")
              ud.send("#{att}=",journal.dval.to_f/(s_unit == 0 ? 1 : s_unit.to_f))
            end
          end

          sum << ud

        end


        #render template: 'journals/month_with_depts'
      end
      format.xls do
        xsl_file = @htlm_journals.to_csv(select: _select) do |item,cols|
          ck_type = Journal::CheckType.rassoc(item.check_type)
          _attrs = item.attributes
          _attrs["check_type"] = ck_type.third
          _attrs["checkin"] = item.checkin.try(:strftime,"%H:%M")
          _attrs["checkout"] = item.checkout.try(:strftime,"%H:%M")
          _attrs["unit"] = ck_type.fourth
          _attrs["holiday_id"] = view_context.dis_episode(item,ck_type,link: false)
          _attrs["state"] = Episode::State.rassoc(item.state).first if item.state
          _attrs["dval"] = case ck_type.last
                           when 0
                             ""
                           when 1
                             item.dval
                           else
                             item.dval.to_f.abs / ck_type.last
                           end
          _attrs["created_at"] = item.created_at.try(:strftime,"%D %T")
          _attrs["updated_at"] = item.updated_at.try(:strftime,"%D %T")
          _attrs.values_at(*cols)#.tap{|t|Rails.logger.info(t.inspect)}
        end
        #xsl_file
        send_data xsl_file
      end
    end
  end
  # GET /journals/1
  # GET /journals/1.json
  def show
  end

  # GET /journals/new
  def new
    drop_breadcrumb("我的考勤",home_users_path)
    drop_page_title("新增异常考勤")
    drop_breadcrumb

    @journal = Journal.new


    @managed_user_list = []
    #部门管理员对直属管理人员有创建权限
    if (con = current_ability.model_adapter(Journal,:create).conditions).kind_of?(Hash) && con[:user_id]
      @managed_user_list = User.where(uid: con[:user_id]).pluck(:user_name,:uid)
    end

    #can?(:change,Department),表示可以对下属部门进行操作
    if can?(:change,Department) && (depts = current_user.role_depts(include_mine: false).presence)
      @managed_user_list.concat(User.not_expired.where(User.is_all_dept?(depts) ? nil : {dept_code: depts}).pluck(:user_name,:uid))
    end
    @managed_user_list = @managed_user_list.uniq.sort_by{|it| it[0]}


  end

  # GET /journals/1/edit
  def edit
    @managed_user_list = []
    #部门管理员对直属管理人员有创建权限
    if (con = current_ability.model_adapter(Journal,:create).conditions).kind_of?(Hash) && con[:user_id]
      @managed_user_list = User.where(uid: con[:user_id]).pluck(:user_name,:uid)
    end

    #can?(:change,Department),表示可以对下属部门进行操作
    if can?(:change,Department) && (depts = current_user.role_depts(include_mine: false).presence)
      @managed_user_list.concat(User.not_expired.where(User.is_all_dept?(depts) ? nil : {dept_code: depts}).pluck(:user_name,:uid))
    end
    @managed_user_list = @managed_user_list.uniq.sort_by{|it| it[0]}
    drop_breadcrumb("我的考勤",home_users_path)
    drop_page_title("修改异常考勤")
    drop_breadcrumb
  end

  # POST /journals
  # POST /journals.json
  def create
    @journal = Journal.new(journal_params)
    _date = @journal.update_date
    _today = Date.today
    #小于上月25号的考勤不能再作修改,27号以后不能再修改本月考勤
    limit_day = OaConfig.setting(:limit_day_of_month).to_i
    if !can?(:create,@journal) && (_date < _today.change(day:limit_day,month: _today.month - 1) || (_today.day > limit_day && _date.day < limit_day))
      raise CanCan::AccessDenied.new("该日考勤已过了确认时间，如需增加请联系人事部门。",new_journal_path ,Journal)
    end
    _cktype = Journal::CheckType.rassoc(@journal.check_type)

    if _cktype && @journal.check_type != 10 #非特批
      _dval = @journal.dval_before_type_cast
      @journal.dval = _dval.to_f.abs * _cktype.last
    end

    respond_to do |format|
      if @journal.save
        format.html { redirect_to new_journal_path, notice: '操作成功,可继续添加!' }
        format.json { render :show, status: :created, location: @journal }
      else
        drop_breadcrumb("我的考勤",home_users_path)
        drop_page_title("新增异常考勤")
        drop_breadcrumb
        flash.now[:alert] = @journal.errors.full_messages
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

      _date = Date.parse(@task.date)
      _today = Date.today
      #小于上月25号的考勤不能再作修改,27号以后不能再修改本月考勤
      limit_day = OaConfig.setting(:limit_day_of_month).to_i
      if _date < _today.change(day:limit_day,month: _today.month - 1) || (_today.day > limit_day && _date.day < limit_day)
        raise CanCan::AccessDenied.new("该日考勤已过了确认时间",kaoqing_users_path("dept") ,params[:task])
      end

      is_mine = @task.leader_user_id == current_user.id
      #if (current_user.roles & ["department_manager","admin"]).blank? && !is_mine
      if !is_mine
        raise CanCan::AccessDenied.new("未授权", home_users_path,params[:task])
      end

      _key,_value = params[:journal].first
      cktype = Journal::CheckType.assoc(_key)
      raise "类型不存在 #{_key}" unless cktype
      @journal = Journal.find_or_initialize_by(user_id: params[:user_id],update_date: params[:date],check_type: cktype.second)
      authorize!(:update,@journal)
      @journal.dval = 0

      if @journal.check_type == 10
        @journal.description = _value
      else
        @journal.description = "#{cktype.third}#{_value}#{cktype.fourth}"
        @journal.dval = _value.to_f.abs * cktype.last
      end

      if @journal.save
        @msg = params[:journal]
      else
        msg = @journal.errors
      end
    elsif params[:id] #管理员编辑
      set_journal
      authorize!(:update,@journal)
      unless @journal.update(journal_params)
        msg = @journal.errors
      end
    else
      msg = {msg:"出错了！"}
    end
    respond_to do |format|
      if msg.blank?
        format.html { redirect_to list_journals_path,notice: "操作成功！" }
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

  def year_journal(check_type_id)
    @year_journals.detect { |e| e.check_type == check_type_id }.try(:dval).to_i
  end
end
