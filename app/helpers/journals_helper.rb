module JournalsHelper
  def dis_dval(item,ck_type)
    case ck_type.last
    when 0
      ""
    when 1
      item.dval
    else
      item.dval.to_f.abs / ck_type.last
    end.to_s + ck_type.fourth

  end

  def dis_episode(item,ck_type,link: true,prompt_new: false,format: :html)
    if ck_type[6].nil?
      ""
    else
      item.episode_id ? (link ? link_to(ck_type[2],episode_url(item.episode_id,format: format),data:{"reveal-id": "modal_window","reveal-ajax": true}) : ck_type[2]) : (prompt_new ? link_to("提交申请",new_episode_path(holiday_id: ck_type[6],journal_id: item.id)) : "无假条")
    end
  end

  def short_dept_name(dept_name)
    dept_name.split('-').last if dept_name
  end

end
