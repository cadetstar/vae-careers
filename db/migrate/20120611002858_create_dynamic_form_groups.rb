class CreateDynamicFormGroups < ActiveRecord::Migration
  def change
    create_table :dynamic_form_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
