class Comment < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  belongs_to :creator, :polymorphic => true

  after_create :send_email

  def destroy
    this_owner = self.owner
    this_creator = self.creator
    super
    "Comment for #{this_owner} by #{this_creator} destroyed."
  end

  def send_email
    GeneralMailer.central_mail(RemoteUser.find_by_email(I18n.t('admins.primary.email')), "A comment has been added to #{self.owner} by #{self.creator}:<br/><br/>#{self.body}", "A comment has been added to #{self.owner}").deliver
  end

  def to_s
    "#{body} by #{creator.to_s} on #{created_at}"
  end

  def self.edittable_attributes
    %w(body)
  end

  def self.body_type_override
    :text_area
  end
end
