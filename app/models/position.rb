class Position < ActiveRecord::Base
  belongs_to :position_type

  def to_s
    position_type
  end
end
