class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles,options: 'default charset=utf8' do |t|
      t.string :name, limit: 20
      t.string :display_name, limit: 30
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :roles, :name
  end
end
