class UserDecorator < ApplicationDecorator
  delegate_all

  def blank_out(med)
    if object.journals.present?
      cktype = Journal::CheckType.assoc(med.to_s)
      #return nil if object.journal.check_type != cktype.second
      _journal = object.journals.detect { |e| e.check_type == cktype.second }
      return nil unless _journal
      if cktype.last == 0
        _journal.description
      elsif cktype.last == 1
        _journal.dval
      else
        _journal.dval.to_f.abs / cktype.last
      end
    else
      nil
    end
  end

 # %w{c_aff_a_points
 # c_aff_b_points
 # c_aff_switch_leave
 # c_aff_comment
 # c_aff_later
 # c_aff_leave
 # c_aff_absent
 # c_aff_forget_checkin
 # c_aff_holiday_year
 # c_aff_sick
 # c_aff_persion_leave
 # c_aff_spec_appr
 # c_aff_holiday_salary
 # c_aff_switch_time
 # c_aff_holiday_maternity
 # c_aff_holiday_acco_maternity
 # c_aff_holiday_marriary
 # c_aff_holiday_funeral
 # c_aff_nursing_later
 # c_aff_nursing_leave
 # c_aff_sick_salary
 # }.each do |item|
 #   define_method item do
 #     send :blank_out,item
 #   end
 # end



  #def initialize
  #  Rails.logger.info("l-----------------")
  #  super
  #end

  #for the leaders
  #return an ReportTitle array

  attr_accessor :report_titles
  attr_accessor :uids
  #def report_titles
  #  @report_title ||= ReportTitle.where(id: object.dept.attend_rule.title_ids).order("ord,id")
  #end

  def index=(ind)
    @index = ind
  end

  def c_line_num
    @index
  end

  def c_dept_name
    object.dept.name.split("-").last
  end

  def c_user_name
    object.user_name
  end

  #带薪事假
  def c_affair_leave
    ( base_holiday_info.affair_leave - year_journal(11) ).to_f/10
  end

  #年假
  def c_holiday_year
    ( base_holiday_info.year_holiday - year_journal(5) ).to_f/10
  end

  #带薪病假
  def c_sick_leaver
    (base_holiday_info.sick_leave - year_journal(17)).to_f/10
  end

  #TODO FIX if for the end_year_time
  #累计贡献分包括特批的分（负值）
  #特批修正只是描述 2015-03-25 09:35 javy_liu
  #a分+b分+基础值
  def c_ab_point
    (base_holiday_info.ab_point + year_journal(9) + year_journal(21) + year_journal(24)+ year_journal(25)).to_f/10
  end

  #TODO FIX if for the end_year_time
  #累计倒休包括特批的时间（负值）
  #特批修正只是描述 2015-03-25 09:35 javy_liu
  def c_switch_leave
    (base_holiday_info.switch_leave + year_journal(8) + year_journal(12)).to_f/10
  end

  def c_checkin
    if @ref_ckin_time
      "#{@ref_ckin_time.strftime("%H:%M:%S") }<br/>#{@ckin_time.strftime("%H:%M:%S") } ".html_safe
    else
      @ckin_time.try(:strftime,"%H:%M:%S")
    end
  end

  def c_checkout
    @ckout_time.try(:strftime,"%H:%M:%S")
  end


  def c_later_time
    "#{@later_time}分钟" if @later_time
  end

  def c_leave_time
    "#{@leave_time}分钟" if @leave_time
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
    ref_cmd.uniq.join("<br>").html_safe
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
  def calculate_journal(attend_rule,date)
    yes_ckin = object.yesterday_checkin

    @ckin_time =  yes_ckin.try(:checkin)
    @ckout_time = yes_ckin.try(:checkout)
    @ref_ckin_time = yes_ckin.try(:ref_time)

    unit = 60/attend_rule.min_unit
    #非工作日，且没有考勤记录，直接返回
    is_work_day = SpecDay.workday?(date: date)
    if !is_work_day && !yes_ckin
      return
    elsif !is_work_day && yes_ckin #非工作日，有考勤
      diff_time = ((@ckout_time - @ckin_time)/60).to_i
      ref_cmd.push("加班")
      #15进制与30进制
      if diff_time >= attend_rule.min_unit/2
        #中午一小时不算加班
        #@b_point = 0
        #start_working_time = @ckin_time
        #end_working_time = @ckout_time
        #ref_cmd.push("加班")
        #if @ckin_time.hour <=12 && @ckout_time.hour >=13
        #  @b_point -= 1
        #elsif @ckin_time.hour > 12 && @ckout_time.hour >=13
        #  start_working_time = @ckin_time.change(hour: 13)
        #elsif @ckin_time.hour <= 12 && @ckout_time.hour < 13
        #  end_working_time = @ckin_time.change(hour: 12)
        #else
        #  start_working_time = end_working_time = 0
        #end
        #@b_point += (((end_working_time - start_working_time)/60).to_i/attend_rule.min_unit.to_f).round.to_f / unit
        @b_point = (diff_time/attend_rule.min_unit.to_f).round.to_f / unit
        @switch_hours = @b_point
      else
        ref_cmd.push("忘打卡")
      end
      episodes.each{|item|ref_cmd.push("<span>#{h.link_to(item.name,"http://kq.press5.cn/episodes/#{item.id}",data: {"reveal-id": "modal_window","reveal-ajax": true})}</span>")} if ref_cmd.present? && episodes.present?
      return
    end


    if yes_ckin
      #工作日
      start_working_time = if attend_rule.time_range == "0" #弹性工作时间
                             if @ckin_time <= @ckin_time.change(hour:9,min:1)
                               end_working_time = @ckin_time.change(hour: 18)
                               @ckin_time.change(hour:9)
                             elsif @ckin_time <= @ckin_time.change(hour:9,min:31)
                               end_working_time = @ckin_time.change(hour: 18,min: @ckin_time.min)
                               @ckin_time
                             else
                               end_working_time = @ckin_time.change(hour: 18,min: 30)
                               @ckin_time.change(hour:9,min:31)
                             end
                           else
                             start_hour,start_min,end_hour,end_min = attend_rule.time_range.split(/[:-]/)
                             end_working_time = @ckin_time.change(hour:end_hour,min:end_min)
                             @ckin_time.change(hour:start_hour,min:start_min)
                           end

      diff_time = ((@ckin_time - start_working_time)/60).to_i #早上打卡时间与工作时间差

      @a_point = @b_point = @switch_hours = 0

      #签入打卡
      if diff_time > 0
        if diff_time <= 30
          ref_cmd.push("迟到")
          @later_time = diff_time
          #@a_point -= 0.5 #-(diff_time/attend_rule.min_unit.to_f).ceil.to_f/unit
          #@switch_hours -= 0.5
        elsif diff_time > 30 && diff_time <= 4*60
          ref_cmd.push("事假0.5天")
        else
          ref_cmd.push("事假1天")
        end

      elsif @ckin_time.tuesday? &&  (_tmp_diff = start_working_time.change(hour: 8) - @ckin_time) > 0 #周二早于8点上班算维护到的情况,截至9点算A分
        @a_point += ((_tmp_diff.to_i/60+60)/attend_rule.min_unit.to_f).round.to_f/unit
        if attend_rule.name == "platform" #平台因不算ab分，所以设置结束工作时间点
          end_working_time = @ckin_time.change(hour: 16)
        elsif attend_rule.id.in?([1,2]) #ab分为工作室
          ref_cmd.push("维护")
        end
      end

      end_diff_time = ((@ckout_time - end_working_time)/60).to_i #结束工作时间点
      #签出打卡
      if end_diff_time < 0 #早退
        end_diff_time = end_diff_time.abs
        if end_diff_time <= 30
          @leave_time = end_diff_time #
          #@a_point -= 0.5 #(end_diff_time/attend_rule.min_unit.to_f).ceil.to_f/unit
          #@switch_hours -= 0.5
          ref_cmd.push("早退")
        elsif end_diff_time > 30 && end_diff_time <= 4*60
          ref_cmd.push("事假0.5天")
        else
          @a_point = 0
          ref_cmd.push("事假1天")
        end
      elsif end_diff_time > 0 #加班
        end_diff_time = ((@ckout_time - @ckout_time.change(hour: 19))/60).to_i
        _tmp = (end_diff_time/attend_rule.min_unit.to_f).round.to_f/unit #加班时长

        #2015-03-30 10:40 javy_liu 更改加班的计算方式 ，_tmp >=2 不准，因为_tmp做了四舍五入计算，如20：45分会被当作加班
        if @ckout_time.hour >= 21  #大于21点签出
          @b_point += _tmp
          @switch_hours += (_tmp - 2)
          ref_cmd.push("加班")
        elsif  _tmp > 0 && attend_rule.name.in?(AttendRule::SpecRuleNames) #小于21点且大于19点签出且是工作室
          ref_cmd.push("加班")
          @a_point += _tmp
        end
      end

      episodes.each{|item|ref_cmd.push("<span>#{h.link_to(item.name,"http://kq.press5.cn/episodes/#{item.id}",data: {"reveal-id": "modal_window","reveal-ajax": true})}</span>")} if ref_cmd.present? && episodes.present?

      #请假#如果没有签到记录，表明该用户本日考勤异常,检查用户是否有请假
    else#记为忘记打卡
      ref_cmd.push("无打卡记录")
      episodes.each{|item|ref_cmd.push("<span>#{h.link_to(item.name,"http://kq.press5.cn/episodes/#{item.id}",data: {"reveal-id": "modal_window","reveal-ajax": true})}</span>")} if episodes.present?
    end
  end

  def wrap(task,users: nil,need_update: false,rule: nil)
    date = task.date || Date.yesterday
    users = users || Task.eager_load_from_task(task,leader_user: self,rule: rule)
    tmp_str = ""
    users.each_with_index do |user,_index|
      user.index = _index + 1
      #用于网页展示和邮件展示时对于需填充字段用不同的class
      cls = if user.ref_cmd.present?
         need_update ? "need_update" : "need_fill"
      end

      tmp_str << h.content_tag(:tr,class: cls,id: user.id,name: cls,data: {object: "journal",url: h.user_journals_path(user.id,date)}) do
        self.report_titles.each do |col|
          _class = col.name.start_with?("c_aff") ? "c_aff" : ""
          _class += " spec_appr" if col.name == "c_aff_spec_appr" #特批那用于描述
          h.concat(h.content_tag(:td,user.send(col.name),id:col.name,class: _class ,data: {attribute: col.name}))
        end
      end
    end
    tmp_str.html_safe
  end

  #参考意见
  def ref_cmd
    @ref_cmd ||= []
  end

  def method_missing(meth,*args,&block)
    if /^c_aff_\w+/=~ meth
      self.class.send :define_method, meth do
        send :blank_out,meth
      end
      self.send(meth)
    else
      super
    end
  end
  #=============For web show=========================================
  #返回当前用户年度假期所需列
  def check_types
    return @check_types if @check_types
    _cktype_ids = object.dept_group.third.dup
    if object.dept_group.first == :group_switch_time && object.title.to_i < 400 #倒休部门经理及以上无倒休
      _cktype_ids.delete(12)
      _cktype_ids.push(8)
    end
    @check_types = Journal::CheckType.select{|item| item.second.in?(_cktype_ids)}
  end

  #UserCheckTypeIds = %w[5 8 9 11 12 17 21]
  def calcute_remain_holiday(check_type)
    _value = case check_type.first
                 when 'c_aff_holiday_year'
                   c_holiday_year
                 when 'c_aff_switch_leave' #加班时长+倒休时长(负值)
                   c_switch_leave
                 when 'c_aff_a_points'
                   c_ab_point
                 when 'c_aff_holiday_salary'
                   c_affair_leave
                 when 'c_aff_switch_time'
                   c_switch_leave
                 when 'c_aff_sick_salary'
                   c_sick_leaver
                 when 'c_aff_b_points'
                   c_ab_point
                 end
    "#{_value} #{check_type.fourth}"
  end

  #得到用户的待处理任务数量
  def pending_task_length(task_type=nil)
    if task_type
      object.group_pending_tasks.try(:assoc,task_type.to_s).try(:last)
    else
      object.pending_tasks
    end.try(:length).to_i
  end

  #======================================================

  private
  def base_holiday_info
    @base_holiday_info ||= (object.last_year_info || object.create_last_year_info)
  end

  def year_journal(check_type_id)
    object.year_journals.detect { |e| e.check_type == check_type_id }.try(:dval).to_i
  end



  #昨天的请假记录,返回请假的名称
  #"holidays.name,episodes.user_id,episodes.id,description,total_time,holiday_id"
  def episodes
    @episodes ||= object.yes_holidays
  end

end
