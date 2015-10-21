class Role < ActiveRecord::Base
  RESERVED = [:admin,:guest]
  has_and_belongs_to_many :users, join_table: :roles_users
  has_many :role_resources, dependent: :destroy

  def self.all_without_reserved
    where("name not in (?)",RESERVED)
  end

  def resource_names
    @resource_names ||= self.role_resources.map{|rr|rr.resource_name}
  end

  def resources
    @resources ||= self.role_resources.map do |rr|
      Resource.find_by_name(rr.resource_name) rescue nil
    end.compact
  end

  #提升性能，重写role_resources 方法，改成从memcache中读取角色的资源
  def role_resources
    @role_resources ||= Rails.cache.fetch("role_resource_#{self.cache_key}") do
      super.to_a
    end
  end
end
