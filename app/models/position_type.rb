class PositionType < ActiveRecord::Base
  has_many :positions

  def self.list_for_select
    PositionType.all.collect{|pt| [pt, pt.id]}
  end

  def destroy
    super
    "Position Type #{self.id}/#{self.name} destroyed."
  end

  def to_s
    name
  end
end
