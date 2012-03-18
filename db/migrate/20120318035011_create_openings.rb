class CreateOpenings < ActiveRecord::Migration
  def change
    create_table :openings do |t|
      t.integer :position_id
      t.integer :department_id
      t.text :description
      t.text :high_priority_description
      t.boolean :active
      t.boolean :show_on_opp

      t.timestamps
    end
  end
end
