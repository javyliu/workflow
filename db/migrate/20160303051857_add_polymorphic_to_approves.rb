class AddPolymorphicToApproves < ActiveRecord::Migration
  def up
    add_column :approves, :approveable_id, :integer
    add_column :approves, :approveable_type, :string

    add_index :approves, [:approveable_id,:approveable_type], name: :approveable_index

    #migrate data
    Approve.update_sql("update approves set approveable_id = episode_id, approveable_type = 'Episode'")
    say "migrate data ok"

    #remove_column :approves, :episode_id
    #say "remove episode_id"
  end

  def down

  end
end
