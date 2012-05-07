class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :owner_type
      t.integer :owner_id
      t.string :creator_type
      t.integer :creator_id

      t.timestamps
    end
  end
end
