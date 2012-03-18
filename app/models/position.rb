class Position < ActiveRecord::Base
  belongs_to :position_type

  def self.list_for_select
    Position.all.collect{|r| ["#{r.position_type} - #{r.time_type}", r.id]}
  end

  def to_s
    position_type
  end
end
