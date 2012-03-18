class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :name
      t.text :prompt
      t.string :type
      t.text :choices
      t.boolean :required

      t.timestamps
    end
  end
end
