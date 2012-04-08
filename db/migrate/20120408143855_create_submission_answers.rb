class CreateSubmissionAnswers < ActiveRecord::Migration
  def change
    create_table :submission_answers do |t|
      t.text :question_text
      t.string :question_type
      t.integer :question_id
      t.text :answer
      t.integer :submission_id
      t.integer :group_order
      t.integer :question_order

      t.timestamps
    end
  end
end
