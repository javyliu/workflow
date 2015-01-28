class UsersController < ApplicationController
  #before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    drop_page_title("我的签到记录")
    drop_breadcrumb
  end

  #确认考勤
  def confirm


  end

  def home
    drop_page_title("我的考勤")
    drop_breadcrumb
    @to_be_confirms = if current_user.pending_tasks
                        current_user.pending_tasks.group_by do |item|
                          item[0..3]
                        end
    end

  end

  def kaoqing
    @to_be_confirm = current_user.pending_tasks.inject([]) do |tasks,item|
      tasks << item if item =~ /^F001/
      tasks
    end

    drop_page_title("部门签到记录")
    drop_breadcrumb

    @rule = AttendRule.find(current_user.leader_data[1])
    uids = uids ||  current_user.leader_data.try(:last)

    @date ||= Date.yesterday
    @users = User.where(uid: uids).includes(:last_year_info,:dept).decorate

    date_checkins = Checkinout.where(user_id: uids,rec_date: @date.to_s).to_a

    yes_holidays = Holiday.select("holidays.*,episodes.user_id user_id").joins(:episodes).where(["user_id in (:users) and start_date <= :yesd and end_date >= :yesd ",yesd: @date.to_s,users: uids]).to_a

    year_journals = Journal.select("id,user_id,check_type,sum(dval) dval").group(:user_id,:check_type).where(["user_id in (?) and update_date > ?",uids,OaConfig.setting(:end_year_time)]).to_a

    journals = Journal.where(["user_id in (?) and update_date > ?",uids,@date]).to_a


    self.current_user = current_user.decorate
    current_user.report_titles = ReportTitle.where(id: @rule.title_ids).order("ord,id")
    current_user.ref_cmd[0] = 0
    @users.each do |item|
      #manually preload yesterday_checkin and yes_holiday
      ass = item.association(:yesterday_checkin)
      ass.loaded!
      ass.target = date_checkins.detect{|_item| _item.user_id == item.id }

      ass = item.association(:yes_holidays)
      ass.loaded!
      ass.target.concat(
        yes_holidays.find_all {|_item| _item.user_id == item.id}
      )

      ass = item.association(:year_journals)
      ass.loaded!
      ass.target.concat(
        year_journals.find_all {|_item| _item.user_id == item.id}
      )

      ass = item.association(:journal)
      ass.loaded!
      ass.target = journals.detect {|_item| _item.user_id == item.id}

      item.calculate_journal(@rule)
      current_user.ref_cmd[0] += item.ref_cmd.length
    end
    #@users.sort!{|a,b| b.ref_cmd.length <=> a.ref_cmd.length }
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:uid, :user_name, :email, :department, :title, :expire_date, :dept_code, :mgr_code, :password_digest, :role_group, :remember_token, :remember_token_expires_at)
    end
end
