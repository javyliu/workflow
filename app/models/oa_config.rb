# == Schema Information
#
# Table name: oa_configs
#
#  id    :integer          not null, primary key
#  key   :string(40)
#  des   :string(40)
#  value :string(255)
#

class OaConfig < ActiveRecord::Base
  after_save :reset_cached

  class << self
    #2015-06-02 13:20 change to memcached
    def setting(key)
      #Sidekiq.redis do |conn|
      #  conn.get("config_#{key.to_s}")
      #end
      Rails.cache.fetch(:oa_config) do
        self.all.to_a
      end.detect{|item| item.key == key.to_s}.value
    end
  end

  private

  def reset_cached
    #Sidekiq.redis do |conn|
    #  OaConfig.all.each do |item|
    #    conn.set("config_#{item.key}",item.value)
    #  end
    #end
    Rails.cache.delete(:oa_config)
  end
end
