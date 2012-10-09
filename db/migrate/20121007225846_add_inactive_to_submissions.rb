class AddInactiveToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :inactive, :boolean

  end
end
