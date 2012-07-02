class NewHireRequest < ActiveRecord::Base
  belongs_to :position
  belongs_to :department
  belongs_to :creator, :class_name => "RemoteUser"

  has_many :new_hire_approvals
  has_many :remote_users, :through => :new_hire_approvals

  default_scope :where => {:deleted => false}

  scope :direct, lambda {|user| where({:creator => user})}

end
