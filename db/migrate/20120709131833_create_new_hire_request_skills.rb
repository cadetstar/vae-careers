class CreateNewHireRequestSkills < ActiveRecord::Migration
  def change
    create_table :new_hire_request_skills do |t|
      t.integer :new_hire_request_id
      t.integer :new_hire_skill_id

      t.timestamps
    end
  end
end
