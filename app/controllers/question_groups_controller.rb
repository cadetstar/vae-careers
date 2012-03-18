class QuestionGroupsController < ApplicationController
  before_filter :is_administrator?, :except => :set_question_groups

  def set_question_groups
    @qg = QuestionGroup.find_by_id(params[:id])

    (params[:questions] || []).each_with_index do |q_id,i|
      if q = Question.find_by_id(q_id)
        qgc = QuestionGroupConnection.find_or_create_by_question_group_id_and_question_id(@qg.id, q.id)
        qgc.question_order = i + 1
      end
    end
    QuestionGroupConnection.where(['question_group_id = ? and question_id not in (?)', @qg.id, (params[:questions] || [-1])]).each do |old_q|
      old_q.destroy
    end
    render :text => ''
  end
end