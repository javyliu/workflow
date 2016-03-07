class AddStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :assault_start_date, :date
    add_column :users, :assault_end_date, :date
  end
end
