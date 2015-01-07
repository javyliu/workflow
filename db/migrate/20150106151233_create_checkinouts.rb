class CreateCheckinouts < ActiveRecord::Migration
  def change
    create_table :checkinouts,options: 'default charset=utf8' do |t|
      t.string :user_id, limit: 20
      t.date :rec_date
      t.datetime :checkin
      t.datetime :checkout
      t.datetime :ref_time

      t.timestamps null: false
    end
    add_index :checkinouts, :user_id
  end
end
