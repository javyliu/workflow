class RoleResource < ActiveRecord::Base
  validates_uniqueness_of :resource_name, scope: :role_id

  belongs_to :role
  #用于批量数量插入
  include ActiveRecordExtension
end
