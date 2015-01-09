class OaConfig < ActiveRecord::Base
  after_save :reset_cached

  class << self
    def setting(key)
      Sidekiq.redis do |conn|
        conn.get("config_#{key.to_s}")
      end
    end
  end

  private

  def reset_cached
    Sidekiq.redis do |conn|
      OaConfig.all.each do |item|
        conn.set("config_#{item.key}",item.value)
      end
    end
  end
end
