class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :tag_type_id
      t.integer :owner_id
      t.string :owner_type
      t.integer :creator_id
      t.string :creator_type

      t.timestamps
    end
  end
end
