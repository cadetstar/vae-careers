class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :creator_id
      t.string :name
      t.string :operates_on
      t.datetime :last_run

      t.timestamps
    end
  end
end
