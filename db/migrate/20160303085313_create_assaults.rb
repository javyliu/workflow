class CreateAssaults < ActiveRecord::Migration
  def change
    create_table :assaults, options: 'default charset=utf8' do |t|
      t.integer :style, limit: 1
      t.string :description
      t.integer :state, limit: 1
      t.string :employees,limit: 600
      t.string :cate, limit: 10
      t.integer :user_id
      t.date :start_date
      t.date :end_date

      t.timestamps null: false
    end

    add_index :assaults, :user_id
  end
end
