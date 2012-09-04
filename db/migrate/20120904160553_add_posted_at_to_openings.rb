class AddPostedAtToOpenings < ActiveRecord::Migration
  def change
    add_column :openings, :posted_at, :datetime

  end
end
