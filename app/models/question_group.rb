class QuestionGroup < ActiveRecord::Base
  has_many :question_group_connections, :order => "group_order"
  has_many :questions, :through => :question_group_connections, :order => "question_group_connections.group_order"

  has_many :opening_group_connections
  has_many :openings, :through => :opening_group_connections

  def self.indexed_attributes
    %w(name questions)
  end

  def to_s
    name
  end

  def questions_for_tooltip
    self.questions.join("<br />")
  end
end
