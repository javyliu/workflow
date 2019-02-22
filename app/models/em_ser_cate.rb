class EmSerCate < ActiveRecord::Base
  has_many :em_services, dependent: :delete_all
  after_save :delete_cache


  def self.cache_all
    Rails.cache.fetch(:em_ser_cates) do
      self.all.to_a
    end
  end

  private
  def delete_cache
    Rails.cache.delete(:em_ser_cates)
  end
end
