class CreateAttendRules < ActiveRecord::Migration
  def change
    create_table :attend_rules,options: 'default charset=utf8' do |t|
      t.string :name, limit: 30
      t.string :description, limit: 40
      t.string :title_ids

      t.timestamps null: false,default: Time.now
    end
  end
end
