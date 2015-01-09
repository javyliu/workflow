class CreateOaConfigs < ActiveRecord::Migration
  def change
    create_table :oa_configs,options: 'default charset=utf8' do |t|
      t.string :key, limit: 40
      t.string :des, limit: 40
      t.string :value
    end
  end
end
