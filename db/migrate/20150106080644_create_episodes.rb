class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes,options: 'default charset=utf8' do |t|
      t.string :user_id, limit: 20
      t.string :title,limit: 20
      t.integer :holiday_id
      t.datetime :start_date
      t.datetime :end_date
      t.string :comment, limit: 500
      t.integer :state,limit: 1,default: 0

      t.timestamps null: false
    end
  end
end
