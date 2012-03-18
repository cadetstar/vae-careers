class CreateQuestionGroupConnections < ActiveRecord::Migration
  def change
    create_table :question_group_connections do |t|
      t.integer :question_id
      t.integer :question_group_id
    end
  end
end
