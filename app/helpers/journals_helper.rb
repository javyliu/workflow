module JournalsHelper
  def dis_dval(item,ck_type)
    case ck_type.last
    when 0
      ""
    when 1
      item.dval
    else
      item.dval.to_f / ck_type.last
    end.to_s + ck_type.fourth

  end

  def dis_episode(item,ck_type,link: true)
    if ck_type[6].nil?
      ""
    else
      Rails.logger.info item.episode_id.inspect
      item.episode_id ? (link ? link_to(ck_type[2],episode_url(item.episode_id)) : ck_type[2]) : "无假条"
    end
  end

end
