class AddIndexesToSubmissionAnswers < ActiveRecord::Migration
  def change
    add_index :submission_answers, [:submission_id, :group_order, :question_order], :name => 'index_submission_answers_on_si_and_go_and_qo'
  end
end
