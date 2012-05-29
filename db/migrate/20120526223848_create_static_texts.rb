class CreateStaticTexts < ActiveRecord::Migration
  def change
    create_table :static_texts do |t|
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
