class ApplicationDecorator < Draper::Decorator
  def self.collection_decorator_class
    PaginatingDecorator
  end

  def created_at
    object.created_at.try(:strftime,"%y-%m-%d %H:%M:%S")
  end

  def updated_at
    object.created_at.try(:strftime,"%y-%m-%d %H:%M:%S")
  end
end
