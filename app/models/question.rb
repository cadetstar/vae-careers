class Question < ActiveRecord::Base
  has_many :question_group_connections
  has_many :question_groups, :through => :question_group_connections
end
