class CreateReportTitles < ActiveRecord::Migration
  def change
    create_table :report_titles,options: 'default charset=utf8' do |t|
      t.string :name, limit: 20
      t.string :des, limit: 20
      t.integer :ord, limit: 2
    end
  end
end
