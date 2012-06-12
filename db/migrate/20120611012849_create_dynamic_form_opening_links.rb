class CreateDynamicFormOpeningLinks < ActiveRecord::Migration
  def change
    create_table :dynamic_form_opening_links do |t|
      t.string :file_type
      t.integer :file_id
      t.integer :opening_id
      t.string :form_type

      t.timestamps
    end
  end
end
