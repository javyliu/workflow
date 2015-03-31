class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals,options: 'default charset=utf8' do |t|
      t.string :user_id, limit: 20
      t.date :update_date
      t.integer :check_type
      t.string :description
      t.integer :dval, limit: 4

      t.timestamps null: false
    end
    add_index :journals, :user_id
  end
end
