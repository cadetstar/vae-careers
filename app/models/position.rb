class Position < ActiveRecord::Base
  belongs_to :position_type
  has_many :openings

  def self.list_for_select
    Position.includes(:position_type).order("position_types.name, time_type").all.collect{|r| ["#{r.position_type} - #{r.time_type}", r.id]}
  end

  def to_s
    position_type.to_s
  end
end
