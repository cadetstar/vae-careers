class CreateDynamicFileRevisions < ActiveRecord::Migration
  def change
    create_table :dynamic_file_revisions do |t|
      t.integer :dynamic_file_id
      t.string :dynamic_file_store
      t.string :uploaded_file_name

      t.timestamps
    end
  end
end
