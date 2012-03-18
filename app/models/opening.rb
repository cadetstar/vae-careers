class Opening < ActiveRecord::Base
  belongs_to :position
  belongs_to :department

  has_many :opening_group_connections, :order => :group_order
  has_many :question_groups, :through => :opening_group_connections

  delegate :time_type, :to => :position
  delegate :city, :state, :to => :department

  default_scope :joins => [:position, :department], :order => 'active DESC, show_on_opp DESC, positions.name, departments.code', :readonly => false

  def self.indexed_attributes
    %w(position time_type department description high_priority_description status)
  end

  def status
    if active
      "Active"
    elsif show_on_opp
      "Show on OPP"
    else
      'Inactive'
    end
  end
end
