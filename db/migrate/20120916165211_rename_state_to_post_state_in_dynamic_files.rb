class RenameStateToPostStateInDynamicFiles < ActiveRecord::Migration
  def up
    rename_column :dynamic_files, :state, :post_state
  end

  def down
    rename_column :dynamic_files, :post_state, :state
  end
end
