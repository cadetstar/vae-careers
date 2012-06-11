class AddCanBeCompiledToDynamicFileRevisions < ActiveRecord::Migration
  def change
    add_column :dynamic_file_revisions, :can_be_compiled, :boolean

  end
end
