class CreateSubmissionUsers < ActiveRecord::Migration
  def change
    create_table :submission_users do |t|
      t.integer :submission_id
      t.integer :remote_user_id

      t.timestamps
    end
  end
end
