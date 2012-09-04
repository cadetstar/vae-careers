class AddCompletedAtToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :completed_at, :datetime

  end
end
