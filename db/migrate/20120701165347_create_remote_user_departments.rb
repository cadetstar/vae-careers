class CreateRemoteUserDepartments < ActiveRecord::Migration
  def change
    create_table :remote_user_departments do |t|
      t.integer :remote_user_id
      t.integer :department_id
      t.string :level

      t.timestamps
    end
  end
end
