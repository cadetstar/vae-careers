class ConvertTypeOnQuestionsToQuestionType < ActiveRecord::Migration
  def up
    rename_column :questions, :type, :question_type
  end

  def down
    rename_column :questions, :question_type, :type
  end
end
