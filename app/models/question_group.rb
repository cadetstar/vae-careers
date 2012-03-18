class QuestionGroup < ActiveRecord::Base
  has_many :question_group_connections
  has_many :questions, :through => :question_group_connections
end
