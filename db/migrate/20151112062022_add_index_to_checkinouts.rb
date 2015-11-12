class AddIndexToCheckinouts < ActiveRecord::Migration
  def change
    add_index :checkinouts, :rec_date#,name: 'ck_type_and_date'
  end
end
