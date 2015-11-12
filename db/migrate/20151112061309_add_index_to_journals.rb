class AddIndexToJournals < ActiveRecord::Migration
  def change
    add_index :journals, :update_date#,name: 'ck_type_and_date'
  end
end
