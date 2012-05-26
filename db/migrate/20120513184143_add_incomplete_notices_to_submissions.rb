class AddIncompleteNoticesToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :incomplete_notices, :text

  end
end
