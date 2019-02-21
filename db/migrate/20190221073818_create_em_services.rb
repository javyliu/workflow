class CreateEmServices < ActiveRecord::Migration
  def change
    create_table :em_services, options: 'default charset=utf8' do |t|
      t.string :title
      t.text :content
      t.integer :em_ser_cate_id

      t.timestamps null: false
    end
    add_index :em_services, :em_ser_cate_id
  end
end
