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
    choices.to_s.gsub(/\r/, '').gsub(/\n/, '<br />')
  end

  def self.indexed_attributes
    %w(name prompt question_type choice_options is_required?)
  end

  def self.migrate_question_type(item, entry)
    item.question_type = Vae::QUESTION_TYPES[%w(boolean mchoice smtext medtext month year label date).index(entry['qtype'])]
  end

  def self.migrate_choices(item, entry)
    item.choices = entry['qchoices'].split('|').join(10.chr)
  end
end
