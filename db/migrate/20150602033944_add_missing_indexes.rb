class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :departments, :attend_rule_id
    add_index :departments, :mgr_code
    add_index :episodes, :holiday_id
    add_index :episodes, :user_id
    add_index :episodes, [:holiday_id, :user_id]
    add_index :users, :dept_code
  end
end
