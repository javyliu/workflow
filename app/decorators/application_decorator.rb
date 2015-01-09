class ApplicationDecorator < Draper::Decorator
  def self.collection_decorator_class
    PaginatingDecorator
  end

  def created_at
    object.created_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
  end

  def updated_at
    object.created_at.try(:strftime,"%Y-%m-%d %H:%M:%S")
  end
end
