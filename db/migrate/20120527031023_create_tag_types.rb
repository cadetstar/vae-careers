class CreateTagTypes < ActiveRecord::Migration
  def change
    create_table :tag_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
