class AddParentIdToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :parent_id, :integer,default: 0
    add_index :episodes, :parent_id
  end
end
