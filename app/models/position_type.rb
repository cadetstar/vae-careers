class PositionType < ActiveRecord::Base
  has_many :positions

  def self.list_for_select
    PositionType.all.collect{|pt| [pt, pt.id]}
  end

  def self.open_types
    PositionType.joins(:positions => :openings).where(["openings.active = ?", true]).select("distinct position_types.id, position_types.name").order("position_types.name")
  end

  def destroy
    super
    "Position Type #{self.id}/#{self.name} destroyed."
  end

  def to_s
    name
  end
end
