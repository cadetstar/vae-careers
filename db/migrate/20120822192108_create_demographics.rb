class CreateDemographics < ActiveRecord::Migration
  def change
    create_table :demographics do |t|
      t.string :gender
      t.string :race
      t.string :veteran

      t.timestamps
    end
  end
end
