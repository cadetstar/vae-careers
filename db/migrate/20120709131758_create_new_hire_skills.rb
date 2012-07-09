class CreateNewHireSkills < ActiveRecord::Migration
  def change
    create_table :new_hire_skills do |t|
      t.string :name

      t.timestamps
    end
  end
end
