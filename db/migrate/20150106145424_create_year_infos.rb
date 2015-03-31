class CreateYearInfos < ActiveRecord::Migration
  def change
    create_table :year_infos,options: 'default charset=utf8' do |t|
      t.integer :year, limit: 4
      t.string :user_id, limit: 20
      t.integer :year_holiday, limit: 4,default: 0
      t.integer :sick_leave, limit: 4,default: 0
      t.integer :affair_leave, limit: 4,default: 0
      t.integer :switch_leave, limit: 4,default: 0
      t.integer :ab_point, limit: 5,default: 0

      t.timestamps null: false
    end
    add_index :year_infos, :user_id
  end
end
