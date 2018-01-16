class AddWorkDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :work_date, :date
  end
end
