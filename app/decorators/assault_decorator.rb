class AssaultDecorator < ApplicationDecorator
  delegate_all

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

end
