class CreatePositionTypes < ActiveRecord::Migration
  def change
    create_table :position_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
