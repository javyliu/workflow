class EpisodeDecorator < ApplicationDecorator
  delegate_all

  def start_date
    object.start_date.try(:strftime,"%Y-%m-%d %H:%M:%S")
  end
  def end_date
    object.end_date.try(:strftime,"%Y-%m-%d %H:%M:%S")
  end

  def state
    Episode::State.rassoc(object.state.to_i).first
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