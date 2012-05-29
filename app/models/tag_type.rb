class TagType < ActiveRecord::Base
  has_many :tags
  has_many :owners, :through => :tags

  def self.description_type_override
    :text_area
  end

  def to_s
    name
  end
end
