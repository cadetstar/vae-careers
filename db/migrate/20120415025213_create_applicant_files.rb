class CreateApplicantFiles < ActiveRecord::Migration
  def change
    create_table :applicant_files do |t|
      t.integer :applicant_id
      t.string :applicant_file_store
      t.string :uploaded_file_name
      t.integer :submission_id

      t.timestamps
    end
  end
end
