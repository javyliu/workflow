class CreateSpecDays < ActiveRecord::Migration
  def change
    create_table :spec_days,options: 'default charset=utf8' do |t|
      t.date :sdate
      t.boolean :is_workday
      t.string :comment,limit: 40
    end
  end
end
