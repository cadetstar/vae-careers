class CreateDynamicFileGroupLinks < ActiveRecord::Migration
  def change
    create_table :dynamic_file_group_links do |t|
      t.integer :dynamic_form_group_id
      t.integer :dynamic_file_id

      t.timestamps
    end
  end
end
