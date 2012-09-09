class Question < ActiveRecord::Base
  has_many :question_group_connections
  has_many :question_groups, :through => :question_group_connections

  def to_s
    "(#{question_type}) #{prompt}"
  end

  def is_required?
    required ? 'Yes' : 'No'
  end

  def choice_options
    choices.gsub(/\r/, '').gsub(/\n/, '<br />')
  end

  def self.indexed_attributes
    %w(name prompt question_type choice_options is_required?)
  end
end
