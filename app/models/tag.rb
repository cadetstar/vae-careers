class Tag < ActiveRecord::Base
  belongs_to :tag_type

  belongs_to :creator, :polymorphic => true
  belongs_to :owner, :polymorphic => true

  delegate :name, :to => :tag_type

  def to_s
    tag_type.to_s
  end

  def self.update_tags(resource, new_tags, user)
    current_tags = resource.tags.collect{|t| t.tag_type_id}
    resource.tag_type_ids = new_tags

    resource.tags.reload.each do |t|
      unless current_tags.include? t.tag_type_id
        t.creator = user
        t.save
      end
    end
  end
end
