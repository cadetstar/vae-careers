class Opening < ActiveRecord::Base
  belongs_to :position
  belongs_to :department

  delegate :time_type, :to => :position
  delegate :city, :state, :to => :department

  def indexed_attributes
    %w(position time_type department description high_priority_description)
  end
end
