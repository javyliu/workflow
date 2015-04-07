class AddCkTypeToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :ck_type, :integer, limit: 1
  end
end
