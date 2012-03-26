class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.text :where_sourced
      t.integer :opening_id
      t.integer :applicant_id
      t.boolean :affidavit
      t.boolean :privacy_notice
      t.string :recruiter_recommendation
      t.boolean :hired
      t.boolean :began_hiring

      t.timestamps
    end
  end
end
