class AddGroupOrderToDynamicFileGroupLink < ActiveRecord::Migration
  def change
    add_column :dynamic_file_group_links, :group_order, :integer
  end
end
