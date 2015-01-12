class UserDecorator < ApplicationDecorator
  delegate_all
  #for the leaders
  #return an ReportTitle array


  def report_titles
    @report_title ||= ReportTitle.where(id: object.dept.attend_rule.title_ids).order("ord,id")
  end

  def c_line_num(index)
    index+1
  end

  def c_dept_name
    object.dept.name
  end

  def c_user_name
    object.user_name
  end

  def c_holiday_year
    ( base_holiday_info.year_holiday - year_journal(5) ).to_f/10
  end

  def c_sick_leaver
    (base_holiday_info.sick_leave - year_journal(6)).to_f/10
  end

  #TODO FIX if for the end_year_time
  def c_ab_point
    (base_holiday_info.ab_point + year_journal(9)).to_f/10
  end

  #TODO FIX if for the end_year_time
  def c_switch_leave
    (base_holiday_info.switch_leave + year_journal(8)).to_f/10
  end
  #TODO in tursday for maintain
  def c_checkin
    yes_ckin = object.yesterday_checkin
    if yes_chin.ref_time
      "#{yes_ckin.ref_time.strftime("%H:%M:%S") }<br/>#{yes_ckin.checkin.strftime("%H:%M:%S") } "
    else
      yes_ckin.checkin.try(:strftime,"%H:%M:%S")
    end
  end

  #TODO in tursday for maintain
  def c_checout
    object.yesterday_checkin.try(:checkout).try(:strftime,"%H:%M:%S")
  end


  def c_later_time
    @later_time
  end

  def c_ref_cmd
    ref_cmd.join(" ")
  end

  def employees
    User.where(uid: uids).includes(:dept,:yesterday_checkins)
  end

  #计算迟到时间，早退时间
  #大于10点算事假，也就是迟到时间大于30分钟
  def calculate_journal
    yes_ckin = object.yesterday_checkin
    if yes_ckin
      ckin_time =  yes_ckin.check_in
      diff_time = ((ckin_time - work_time)/60).round
      case
      when diff_time > 30
        #迟到,如大于30分钟，无请假则算漏打卡
        if episode
          ref_cmd.push(episode.name)
        else
          ref_cmd.push("漏打卡")
        end
      when 0 < diff_time <=30
        @leave_time = (diff_time/30).ceil.to_f/2
        ref_cmd.push("迟到")
      when diff_time < 15 * 6
        #8点前打卡为维护人员(1.5 * 60)即提前1个半小时上班,提供A分或倒休,到10点都可计入A分
        if object_leader_rule.in?(["ab_point","ab_point4_qiLe"])
          @aff_a_point = (diff_time.to_i.abs/30).to_f/2 + 0.5
          ref_cmd.push("维护")
        else
          @switch_leave = (diff_time.abs/30).to_f/2 + 0.5
          ref_cmd.push("维护")
        end

      end
      if diff_time > 30
        later_mins = diff_time/60
        ref_cmd.push("漏打卡")
        #以30分钟为单位，返回小时浮点数
        @later_time = (later_mins/30).ceil.to_f/2
       if @later_time > 0.5
          @later_time = false
       else
         @c_ref_cmd = ""
       end
      #维护人员
      elsif diff_time < 1.5*60
        case object.leader_rule
        when "ab_point4_qiLe"
        when "ab_point"
        when "flexibal_working_time"
        end
      end
    #请假#如果没有签到记录，表明该用户本日考勤异常,检查用户是否有请假
    elsif episode
     ref_cmd.push episode.name
    #记为忘记打卡
    else
      ref_cmd.push("漏打卡")
    end
  end

  private
  def base_holiday_info
    @base_holiday_info ||= (object.last_year_info || object.create_last_year_info)
  end

  def year_journal(check_type_id)
    @year_journal ||= object.detect { |e| e.check_type == check_type_id }
    @year_journal.try(:dval).to_i
  end

  def work_time
    @work_time ||= Date.yesterday.change(hour: 9,min:30)
  end

  #参考意见
  def ref_cmd
    @ref_cmd || []
  end

  #昨天的请假记录,返回请假的名称
  def episode
     @episode ||= object.yes_holidays.first
  end

  def working_date
    @working_date ||=SpecDay.workday?(Date.yesterday)
  end


end
