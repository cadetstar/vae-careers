class ChangeQuestionOrderToGroupOrder < ActiveRecord::Migration
  def up
    rename_column :question_group_connections, :question_order, :group_order
  end

  def down
    rename_column :question_group_connections, :group_order, :question_order
  end
end
