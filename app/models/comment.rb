class Comment < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  belongs_to :creator, :polymorphic => true

  def destroy
    this_owner = self.owner
    this_creator = self.creator
    super
    "Comment for #{this_owner} by #{this_creator} destroyed."
  end
end
