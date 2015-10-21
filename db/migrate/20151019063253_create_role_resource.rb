class CreateRoleResource < ActiveRecord::Migration
  def change
    create_table :role_resources,options: 'default charset=utf8' do |t|
      t.integer :role_id
      t.string :resource_name, limit: 50
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :role_resources, :role_id
    add_index :role_resources, :resource_name
  end
end
