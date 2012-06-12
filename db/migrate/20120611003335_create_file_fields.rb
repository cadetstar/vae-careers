class CreateFileFields < ActiveRecord::Migration
  def change
    create_table :file_fields do |t|
      t.integer :dynamic_file_revision_id
      t.string :field_name
      t.text :system_data

      t.timestamps
    end
  end
end
