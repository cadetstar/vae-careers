class Position < ActiveRecord::Base
  belongs_to :position_type
  has_many :openings

  def self.list_for_select
    Position.includes(:position_type).order("positions.name, time_type").all.collect{|r| ["#{r} - #{r.time_type}", r.id]}
  end

  def to_s
    name
  end

  def time_type_abbreviation
    Vae::TIME_TYPES[time_type]
  end

  def destroy
    if self.openings.size > 0
      "You cannot destroy this position as it has openings attached."
    else
      super
      "Position #{self.id}/#{self.name} destroyed."
    end
  end
end
