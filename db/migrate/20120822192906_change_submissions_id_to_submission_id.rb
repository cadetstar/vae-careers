class ChangeSubmissionsIdToSubmissionId < ActiveRecord::Migration
  def up
    rename_column :demographics, :submissions_id, :submission_id
  end

  def down
    rename_column :demographics, :submission_id, :submissions_id
  end
end
