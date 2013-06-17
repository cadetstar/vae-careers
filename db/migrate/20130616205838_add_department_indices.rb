class AddDepartmentIndices < ActiveRecord::Migration
  def up
    add_index :departments, :manager_id
    add_index :departments, :supervisor_id

    add_index :remote_user_departments, [:remote_user_id, :department_id], :name => 'index_rud_on_rui_and_dept_id'
  end

  def down
    remove_index :departments, :manager_id
    remove_index :departments, :supervisor_id

    remove_index :remote_user_departments, :name => 'index_rud_on_rui_and_dept_id'
  end
end
