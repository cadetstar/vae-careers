class Opening < ActiveRecord::Base
  belongs_to :position
  belongs_to :department

  has_many :opening_group_connections, :order => :group_order
  has_many :question_groups, :through => :opening_group_connections, :order => "opening_group_connections.group_order"

  has_many :submissions
  has_many :applicants, :through => :submissions

  has_many :dynamic_form_opening_links

  has_many :pre_dynamic_file_links, :class_name => "DynamicFormOpeningLink", :conditions => {:form_type => 'pre'}
  has_many :post_dynamic_file_links, :class_name => "DynamicFormOpeningLink", :conditions => {:form_type => 'post'}

  has_many :pre_dynamic_files, :through => :dynamic_form_opening_links
  has_many :pre_dynamic_form_groups, :through => :dynamic_form_opening_links

  has_many :post_dynamic_files, :through => :dynamic_form_opening_links
  has_many :post_dynamic_form_groups, :through => :dynamic_form_opening_links

  has_many :demographics

  delegate :name, :time_type, :position_type, :time_type_abbreviation, :to => :position, :allow_nil => true
  delegate :city, :state, :city_state, :to => :department, :allow_nil => true

  scope :public, :joins => [:position, :department], :order => 'active DESC, show_on_opp DESC, positions.name, departments.code', :readonly => false
  default_scope :order => 'active DESC, show_on_opp DESC'

  def self.indexed_attributes
    %w(position time_type department description high_priority_description status)
  end

  def self.current_openings
    Opening.joins([:position, :department]).where(:active => true).order("positions.name, departments.state")
  end

  def to_s
    "#{position.to_s} - #{department.try(:city_state)}"
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
