class CreateDynamicFiles < ActiveRecord::Migration
  def change
    create_table :dynamic_files do |t|
      t.string :name
      t.integer :current_version_id
      t.text :confirmation_notice

      t.timestamps
    end
  end
end
