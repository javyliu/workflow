class AddIrregularToYearInfos < ActiveRecord::Migration
  def change
    add_column :year_infos, :irregular, :integer, default: 0
  end
end
