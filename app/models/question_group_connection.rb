class QuestionGroupConnection < ActiveRecord::Base
  belongs_to :question
  belongs_to :question_group
end
