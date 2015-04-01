class CheckinoutDecorator < ApplicationDecorator
  delegate_all

  def checkin
    object.checkin.strftime("%H:%M")
  end

  def checkout
    object.checkout.strftime("%H:%M")
  end

  def ref_time
    object.ref_time.strftime("%H:%M")
  end

  def user_name
    object.try(:user).try(:user_name)
  end
  def dept_name
    object.try(:user).try(:dept).try(:name)
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
