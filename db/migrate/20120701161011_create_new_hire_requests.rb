class CreateNewHireRequests < ActiveRecord::Migration
  def change
    create_table :new_hire_requests do |t|
      t.integer :position_id
      t.integer :department_id
      t.integer :creator_id
      t.boolean :replacement
      t.string :incumbent
      t.string :proposed_wage
      t.string :budgeted_wage
      t.text :reason_for_request
      t.text :criteria
      t.integer :status, :default => 0
      t.datetime :posted_time
      t.datetime :filled_time
      t.boolean :deleted, :default => false

      t.timestamps
    end
  end
end
