class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.text :data
      t.integer :applicant_id
      t.string :phone_type

      t.timestamps
    end
  end
end
