class CreateDepartments < ActiveRecord::Migration
  def up
    create_table :departments,id: false,options: 'default charset=utf8',force: true do |t|
      t.string :code, limit: 20#,null: false
      t.string :name, limit: 100
      t.integer :attend_rule_id, limit: 2
      t.string :mgr_code, limit: 20
      t.string :admin, limit: 20

      t.timestamps null: false,default: Time.now
    end
    execute %{ alter table departments add primary key (code);}
  end
  def down
    drop_table :departments
  end
end
