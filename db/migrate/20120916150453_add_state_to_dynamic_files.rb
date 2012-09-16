class AddStateToDynamicFiles < ActiveRecord::Migration
  def change
    add_column :dynamic_files, :state, :string

  end
end
