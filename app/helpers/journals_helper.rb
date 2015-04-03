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

end
