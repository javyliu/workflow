class AttendRuleDecorator < ApplicationDecorator
  delegate_all

  def titles
    ReportTitle.where(id: object.title_ids)
  end

end
