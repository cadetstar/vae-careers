class CreateOpeningGroupConnections < ActiveRecord::Migration
  def change
    create_table :opening_group_connections do |t|
      t.integer :opening_id
      t.integer :question_group_id
      t.integer :group_order

      t.timestamps
    end
  end
end
