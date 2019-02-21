class CreateEmSerCates < ActiveRecord::Migration
  def change
    create_table :em_ser_cates, options: 'default charset=utf8' do |t|
      t.string :name, limit: 30
      t.timestamps null: false
    end
  end
end
