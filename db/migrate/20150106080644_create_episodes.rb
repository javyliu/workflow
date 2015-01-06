class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.string :user_id, limit: 20
      t.integer :holiday_id
      t.date :start_date
      t.date :end_date
      t.string :comment, limit: 500
      t.string :approved_by, limit: 20
      t.datetime :approved_time

      t.timestamps null: false
    end
  end
end
