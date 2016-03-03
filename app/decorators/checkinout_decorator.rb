class CheckinoutDecorator < ApplicationDecorator
  delegate_all

  def checkin
    object.checkin.try(:strftime,"%H:%M")
  end

  def checkout
    object.checkout.try(:strftime,"%H:%M")
  end

  def ref_time
    object.ref_time.try(:strftime,"%H:%M")
  end

  def user_name
    object.try(:user).try(:user_name)
  end
  def dept_name
    h.short_dept_name(object.try(:user).try(:dept).try(:name))
  end

  def description
    tmp_str = ''
    return tmp_str unless object.user
    if object.description.present?
      object.description.split("<br>").each do |item|
        id,text = item.split('!!')
        tmp_str << h.link_to(text || '无描述',h.journal_path(id,format: :js),data:{"reveal-id": "modal_window","reveal-ajax": true})
        tmp_str << "&nbsp;"
      end
    else
      is_work_day = SpecDay.workday?(date: object.rec_date)

      #小于9小时就是异常，非工作日有记录是异常
      text = if !is_work_day
               '非工作日加班'
             elsif (object.checkout - object.checkin) < 32400
               '工时不足8小时'
             else
               ckin_time = object.checkin
               start_working_time,end_working_time = regular_working_time
               #非正常工作时间上下班都为异常
               if ckin_time > start_working_time || object.checkout < end_working_time
                 '上下班异常'
               else
                 nil
               end
             end
      if text && leader_id = User.cached_leaders.detect{|it|it[2].include?(object.user_id.to_s)}.try(:first)
        task_name = "F001:#{leader_id}:#{object.rec_date}"
        tmp_str << h.link_to(h.kaoqing_users_path(task_name,cmd: 'update')) do
          h.concat(h.content_tag(:span,text,class: 'alert label'))
        end
      else
        return nil
      end

      #return h.content_tag(:span,'非工作日加班',class: 'alert label')  if !is_work_day
      #return h.content_tag(:span,'工时不足8小时',class: 'alert label')  if (object.checkout - object.checkin) < 32400
      #return h.content_tag(:span,'上下班异常',class: 'alert label')  if ckin_time > start_working_time || object.checkout < end_working_time

    end
    tmp_str.html_safe
  end

  def regular_working_time
    ckin_time = object.checkin
    #设置该用户的正常工作时间

    time_range = object.user.rule[3] rescue (Rails.logger.debug{ "no_rule_error: #{object.user_id}"}; "0")
    #Rails.logger.debug {"-------------#{time_range}--"}
    if time_range == "0" #弹性工作时间
      if ckin_time <= ckin_time.change(hour:9,min:1)
        [ckin_time.change(hour:9,min: 1),ckin_time.change(hour: 18)]
      elsif ckin_time <= ckin_time.change(hour:9,min:31)
        [ckin_time,ckin_time.change(hour: 18,min: ckin_time.min)]
      else
        [ckin_time.change(hour:9,min:31),ckin_time.change(hour: 18,min: 30)]
      end
    else
      start_hour,start_min,end_hour,end_min = time_range.split(/[:-]/)
      [ckin_time.change(hour:start_hour,min:start_min), ckin_time.change(hour:end_hour,min:end_min)]
    end

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
