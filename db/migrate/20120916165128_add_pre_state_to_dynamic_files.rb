class AddPreStateToDynamicFiles < ActiveRecord::Migration
  def change
    add_column :dynamic_files, :pre_state, :string

  end
end
