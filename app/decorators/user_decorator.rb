class UserDecorator < ApplicationDecorator
  delegate_all

  def blank_out
    nil
  end

  alias c_aff_points blank_out
  alias c_aff_switch_leave blank_out
  alias c_aff_comment blank_out
  alias c_aff_later blank_out
  alias c_aff_leave blank_out
  alias c_aff_absent blank_out
  alias c_aff_forget_checkin blank_out
  alias c_aff_holiday_year blank_out
  alias c_aff_sick blank_out
  alias c_aff_persion_leave blank_out

  #def initialize
  #  Rails.logger.info("l-----------------")
  #  super
  #end

  #for the leaders
  #return an ReportTitle array

  def report_titles
    @report_title ||= ReportTitle.where(id: object.dept.attend_rule.title_ids).order("ord,id")
  end

  def c_line_num
    @index
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

  def c_checkin
    if @ref_ckin_time
      "#{@ref_ckin_time.strftime("%H:%M:%S") }<br/>#{@ckin_time.strftime("%H:%M:%S") } "
    else
      @ckin_time.try(:strftime,"%H:%M:%S")
    end
  end

  def c_checout
    @ckout_time.try(:strftime,"%H:%M:%S")
  end


  def c_later_time
    @later_time
  end

  def c_leave_time
    @later_time
  end

  def c_a_point
    @a_point
  end

  def c_b_point
    @b_point
  end

  def c_switch_hours
    @switch_hours
  end

  def c_ref_cmd
    ref_cmd.uniq.join(" ")
  end



  # 好
  #def method_missing(meth, *args, &block)
  #  if /^c_aff_(?<prop>.*)/ =~ meth
  #    find_by(prop, *args, &block)
  #  else
  #    super
  #  end
  #end
  #         # 而最好是在每个可以找到的属性被宣告时，使用 define_method。


  #计算迟到时间，早退时间
  #大于10点算事假，也就是迟到时间大于30分钟
  def calculate_journal(attend_rule,index)
    @index = index + 1
    yes_ckin = object.yesterday_checkin
    if yes_ckin
      @ckin_time =  yes_ckin.checkin
      @ckout_time = yes_ckin.checkout
      @ref_ckin_time = yes_ckin.ref_time

      unit = 60/attend_rule.min_unit

      #非工作日
      unless working_date
        diff_time = ((ckout_time - ckin_time)/60).to_i
        if diff_time >= attend_rule.min_unit/2
          ref_cmd.push("加班")
          @b_point = (diff_time/attend_rule.min_unit.to_f).round.to_f / unit
          @switch_hours = @b_point
        end
        return
      end


      #工作日
      start_working_time = if attend_rule.time_range == "0" #弹性工作时间
                             if ckin_time <= ckin_time.change(hour:9)
                               end_working_time = ckin_time.change(hour: 18)
                               ckin_time.change(hour:9)
                             else
                               end_working_time = ckin_time.change(hour: 18,min: 30)
                               ckin_time.change(hour:9,min:30)
                             end
                           else
                             start_time,end_time = attend_rule.time_range.split("-").first
                             start_hour,start_min = start_time.split(":")
                             end_hour,end_min = end_time.split(":")
                             end_working_time = ckin_time.change(hour:end_hour,min:end_min)
                             ckin_time.change(hour:start_hour,min:start_min)
                           end

      end_diff_time = ((ckout_time - end_working_time)/60).to_i #结束工作时间点
      diff_time = ((ckin_time - start_working_time)/60).to_i #早上打卡时间与工作时间差

      @a_point = 0

      #签入打卡
      if diff_time > 0
        if episode
          ref_cmd.push(episode.name)
        else
          if diff_time <= 30
            ref_cmd.push("迟到")
            @later_time = diff_time
            @a_point -= 0.5 #-(diff_time/attend_rule.min_unit.to_f).ceil.to_f/unit
          elsif diff_time > 30 && diff_time <= 2*60
            ref_cmd.push("事假半天")
          else
            ref_cmd.push("事假一天")
          end
        end
      elsif ckin_time.tuesday? &&  (_tmp_diff = start_working_time.change(hour: 8) - ckin_time) > 0 #周二早于8点上班算维护到的情况
        @a_point += ((_tmp_diff+60)/attend_rule.min_unit.to_f).round.to_f/unit
        end_working_time = ckin_time.change(hour: 16) if attend_rule.name == "platform" #平台因不算ab分，所以设置结束工作时间点
        ref_cmd.push("维护")
      end

      #签出打卡
      if end_diff_time < 0 #早退
        if episode
          ref_cmd.push(episode.name)
        else
          end_diff_time = end_diff_time.abs
          if end_diff_time <= 30
            ref_cmd.push("早退")
            @leave_time = end_diff_time #
            @a_point -= 0.5 #(end_diff_time/attend_rule.min_unit.to_f).ceil.to_f/unit
          elsif end_diff_time > 30 && end_diff_time <= 2*60
            ref_cmd.push("事假半天")
          else
            ref_cmd.push("事假一天")
          end
        end
      elsif end_diff_time > 0 #加班
        if ckout_time <= ckout_time.change(hour: 21)
          @a_point += ((end_diff_time)/attend_rule.min_unit.to_f).round.to_f/unit
        else
          @b_point = ((end_diff_time)/attend_rule.min_unit.to_f).round.to_f/unit
          @switch_hours = @b_point
        end
      end

    elsif episode #请假#如果没有签到记录，表明该用户本日考勤异常,检查用户是否有请假
      ref_cmd.push episode.name
    else#记为忘记打卡
      ref_cmd.push("无打卡记录")
    end
  end

  def wrap
    cls = ref_cmd.length.blank? ? "" : "need_fill"
    h.content_tag(:tr,class: cls) do
      report_titles.each do |col|
        h.concat(h.content_tag(:td,self.send(col.name),class: col.name))
      end
    end
  end

  private
  def base_holiday_info
    @base_holiday_info ||= (object.last_year_info || object.create_last_year_info)
  end

  def year_journal(check_type_id)
    @year_journal = object.year_journals.detect { |e| e.check_type == check_type_id }
    @year_journal.try(:dval).to_i
  end


  #参考意见
  def ref_cmd
    @ref_cmd ||= []
  end

  #昨天的请假记录,返回请假的名称
  def episode
    @episode ||= object.yes_holidays.first
  end

  def working_date
    @working_date ||=SpecDay.workday?(Date.yesterday)
  end


end
