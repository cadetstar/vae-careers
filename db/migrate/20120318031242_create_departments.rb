class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.string :city
      t.string :state
      t.string :code
      t.integer :supervising_department_id
      t.integer :manager_id
      t.integer :supervisor_id

      t.timestamps
    end
  end
end
