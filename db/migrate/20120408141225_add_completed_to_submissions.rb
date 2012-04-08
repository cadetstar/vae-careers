class AddCompletedToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :completed, :boolean

  end
end
