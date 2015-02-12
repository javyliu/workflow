class CreateApproves < ActiveRecord::Migration
  def change
    create_table :approves,options: 'default charset=utf8' do |t|
      t.integer :user_id
      t.string :user_name, limit: 20
      t.integer :state,limit: 1,default: 0
      t.string :des
      t.integer :episode_id

      t.timestamps null: false
    end
    add_index :approves, :user_id
    add_index :approves, :episode_id
  end
end
