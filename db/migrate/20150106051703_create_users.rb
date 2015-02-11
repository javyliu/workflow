class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users,id: false, options: 'default charset=utf8',force: true do |t|
      t.string :uid, limit: 20
      t.string :user_name, limit: 20,null: false
      t.string :email, limit: 40
      t.string :department
      t.string :title
      t.date :expire_date
      t.string :dept_code, limit: 20
      t.string :mgr_code, limit: 20
      t.string :password_digest
      t.integer :role_group
      t.string :remember_token
      t.date :onboard_date
      t.date :regular_date

      t.datetime :remember_token_expires_at

      t.timestamps null: false,default: Time.now
    end
    add_index :users, :email
    add_index :users, :mgr_code

    execute %{ alter table users add primary key (uid);}
  end
  def down
    drop_table :users
  end
end
