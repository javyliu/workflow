class CreateUserJoinTable < ActiveRecord::Migration
  def change
    create_join_table :users, :roles do |t|
      # t.index [:user_id, :role_id]
      t.index [:role_id, :user_id], unique: true
    end
  end
end
