class AddQuestionOrderToQuestionGroupConnections < ActiveRecord::Migration
  def change
    add_column :question_group_connections, :question_order, :integer
  end
end
