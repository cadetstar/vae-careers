class NewHireRequest < ActiveRecord::Base
  STATUSES = %w(Not\ Yet\ Submitted Posted Filled Submitted Held Rejected)

  belongs_to :position
  belongs_to :department
  belongs_to :creator, :class_name => "RemoteUser"

  belongs_to :opening

  has_many :new_hire_approvals
  has_many :remote_users, :through => :new_hire_approvals, :order => "new_hire_approvals.created_at"

  has_many :new_hire_request_skills
  has_many :new_hire_skills, :through => :new_hire_request_skills

  default_scope where(:deleted => false)

  scope :direct, lambda {|user| where({:creator_id => user.id})}

  before_create {status = 'Not Yet Submitted'}

  def destroy
    self.update_attributes({:deleted => true})
    "#{self.to_s} destroyed."
  end

  def to_s
    "NHR - #{position} - #{department} by #{creator}"
  end

  def status
    STATUSES[self.attributes[:status] || 0]
  end

  def status=(val)
    self.attributes[:status] = STATUSES.index(val)
  end
end
