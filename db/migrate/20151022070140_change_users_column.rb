class ChangeUsersColumn < ActiveRecord::Migration
  def change
    change_column :users,:department,:string,limit: 3000
  end
end
