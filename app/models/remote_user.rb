class RemoteUser < ActiveRecord::Base
  has_many :comments, :as => :creator
  has_many :tags, :as => :creator

  has_many :remote_user_departments
  has_many :departments, :through => :remote_user_departments

  has_many :managed_departments, :class_name => "Department", :foreign_key => :manager_id
  has_many :supervised_departments, :class_name => "Department", :foreign_key => :supervisor_id

  has_many :new_hire_approvals
  has_many :new_hire_requests, :through => :new_hire_approvals

  ROLES = %w(administrator email_administrator)

  attr_protected :id, :roles_mask

  def to_s
    [first_name, last_name].compact.join(' ')
  end

  def subordinate_requests
    self.supervised_departments.collect{|sd| sd.manager.subordinate_requests + sd.manager.new_hire_requests}.flatten.uniq
  end

  def self.with_role(role)
    User.where(['roles_mask & ? > 0', 2**ROLES.index(role.to_s)]).all
  end

  def roles=(roles)
    roles.reject!{|r| !r.match(/^careers/i)}
    roles = roles.collect{|r| r.gsub(/^careers_/, '')}
    self.roles_mask = (roles & ROLES).map {|r| 2**ROLES.index(r)}.sum
  end

  def roles
    ROLES.reject{ |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero?}
  end

  def has_role?(role)
    self.roles.include?(role.to_s)
  end

  def self.edittable_attributes
    %w(notification_time new_hire_expiration)
  end

  def tooltip
    to_s
  end

  private

  def method_missing(name, *args)
    if name.match(/\?$/) and ROLES.include?(name.to_s.gsub(/\?$/, ''))
      self.has_role?(name.to_s.gsub(/\?$/, ''))
    else
      super
    end
  end
end
