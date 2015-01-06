class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays,options: 'default charset=utf8' do |t|
      t.string :name
    end
  end
end
