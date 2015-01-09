class UserDecorator < ApplicationDecorator
  delegate_all
=begin
  ['c_line_num','行号'],
  ['c_dept_name','部门'],
  ['c_user_name','姓名'],
  ['c_holiday_year','剩余年假'],
  ['c_sick_leaver','剩余带薪病假'],
  ['c_ab_point','累计贡献分'],
  ['c_switch_leave','累计倒休'],
  ['c_checkin','签入'],
  ['c_checkout','签出'],
  ['c_later_time','迟到时长'],
  ['c_leave_time','早退时长'],
  ['c_ref_cmd','参考意见'],
  ['c_aff_a_point','A'],
  ['c_aff_b_point','B'],
  ['c_aff_points','确认贡献分'],
  ['c_aff_switch_leave','确认倒休'],
  ['c_aff_comment','额外说明'],
  ['c_aff_later','迟到'],
  ['c_aff_leave','早退'],
  ['c_aff_absent','旷工'],
  ['c_aff_forget_checkin','漏打卡'],
  ['c_aff_holiday_year','年假'],
  ['c_aff_sick','病假'],
  ['c_aff_persion_leave','事假']
=end
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


  end

  def employees
    User.where(uid: uids).includes(:dept,:yesterday_checkins)
  end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
