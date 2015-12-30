class EpisodeDecorator < ApplicationDecorator
  delegate_all

  def start_date
    object.start_date.try(:strftime,"%y/%m/%d %H:%M")
  end
  def end_date
    object.end_date.try(:strftime,"%y/%m/%d %H:%M")
  end

  def state
    _state = object.state.to_i
    css = case _state
           when 0
             'alert'
           when 2
             'secondary'
           when 1
             'success'
           else
             'warning'
           end

    h.content_tag(:span,Episode::State.rassoc(_state).first,class: "label #{css}")
  end

  def user_name
    object.user.try(:user_name)
  end

  def dept_name
    object.user.try(:dept).try(:name)
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
