class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string :name
      t.text :description
      t.integer :position_type_id
      t.string :time_type

      t.timestamps
    end
  end
end
