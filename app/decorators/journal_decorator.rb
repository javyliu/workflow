class JournalDecorator <  Draper::Decorator
  delegate_all

  #attr_reader :user
  #attr_accessor :dept_name,:user_name,:user_id,:remain_switch_time,:remain_holiday_year,:remain_sick_salary,:remain_affair_salary
  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def user
    @journal_user ||= object[1][0].user
  end

  #是否转正
  def regular_date
    return nil unless user
    if user.regular_date.present? && user.regular_date > Date.today
      user.regular_date
    elsif user.regular_date.nil? && user.onboard_date + 3.months > Date.today
      "试用中"
    end
  end

  def dept_name
    user and user.dept.name
  end

  def user_name
    user and user.user_name
  end

  def user_id
    object[0]
  end

  def remain_holiday_year
    #年假
    #Rails.logger.debug {user.inspect}
    user and ( base_holiday_info.year_holiday - year_journal(5) ).to_f/10
  end

  def remain_switch_time
    #倒休
    #binding.pry
    user and (base_holiday_info.switch_leave + year_journal(8) + year_journal(12)).to_f/10
  end
  #带薪病假
  def remain_sick_salary
    user and (base_holiday_info.sick_leave - year_journal(17)).to_f/10
  end
  #带薪事假
  def remain_affair_salary
    user and ( base_holiday_info.affair_leave - year_journal(11) ).to_f/10
  end
  #ab分
  def remain_ab_points
   user and (base_holiday_info.ab_point + year_journal(9) + year_journal(21) + year_journal(24)+ year_journal(25)).to_f/10
  end

  def method_missing(meth,*args,&block)
    if /^c_aff_\w+/=~ meth
      self.class.send :define_method, meth do |arg = false|
        send :blank_out,meth,arg
      end
      self.send(meth,args.first)
    else
      super
    end
  end

  private
  def base_holiday_info
    @base_holiday_info ||= (user.last_year_info || user.create_last_year_info)
  end


  def blank_out(med,comments = false)
    cktype = Journal::CheckType.assoc(med.to_s)
    _journal = object[1].detect { |e| e.check_type == cktype[1] }
    return nil unless _journal
    #返回异常考勤日期说明
    return _journal.comments if comments
    if cktype.last == 0
      _journal.description
    elsif cktype.last == 1
      _journal.dval
    else
      _journal.dval.to_f / cktype.last
    end
  end

  #object like this
  #["1002",
  # [<Journal:0xc63d3f8 id: 5651, user_id: "1002">,
  #  #<Journal:0xc63d344 id: 5652, user_id: "1002">,
  #  #<Journal:0xc63d290 id: 5653, user_id: "1002">,
  #  #<Journal:0xc63d1dc id: 5654, user_id: "1002">,
  #  #<Journal:0xc63d128 id: 5655, user_id: "1002">,
  #  #<Journal:0xc63d074 id: 1, user_id: "1002">,
  #  #<Journal:0xc63cfc0 id: 5646, user_id: "1002">,
  #  #<Journal:0xc63cf0c id: 5647, user_id: "1002">,
  #  #<Journal:0xc63ce58 id: 5648, user_id: "1002">,
  #  #<Journal:0xc63cda4 id: 5649, user_id: "1002">,
  #  #<Journal:0xc63ccf0 id: 5650, user_id: "1002">]]
  #
  def year_journal(check_type_id)
    user.year_journals.detect { |e| e.check_type == check_type_id }.try(:dval).to_i
  end

end
