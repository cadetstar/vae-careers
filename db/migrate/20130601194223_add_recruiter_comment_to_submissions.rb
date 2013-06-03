class AddRecruiterCommentToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :recruiter_comment, :text

  end
end
