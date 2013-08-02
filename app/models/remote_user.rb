class RemoteUser < ActiveRecord::Base
  has_many :comments, :as => :creator
  has_many :tags, :as => :creator

  has_many :remote_user_departments
  has_many :departments, :through => :remote_user_departments

  has_many :submission_users, :dependent => :destroy
  has_many :submissions, :through => :submission_users

  has_many :managed_departments, :class_name => "Department", :foreign_key => :manager_id
  has_many :supervised_departments, :class_name => "Department", :foreign_key => :supervisor_id

  has_many :new_hire_approvals
  has_many :new_hire_requests, :through => :new_hire_approvals

  ROLES = %w(administrator email_administrator)

  attr_protected :id, :roles_mask

  default_scope where(:inactive => [false, nil])

  def to_s
    [first_name, last_name].compact.join(' ')
  end

  def supervisor_tree(depth = 0)
    (self.departments + self.managed_departments).collect do |d|
      if d.supervising_department == d
        nil
      elsif depth > 8
        nil
      else
        ([d.manager] + d.supervising_department.users).uniq.collect do |e|
          if self == e
            nil
          else
            e.supervisor_tree(depth + 1)
          end
        end
      end
    end.flatten.uniq.compact
  end

  def subordinate_requests(trace = [])
    self.supervised_departments.collect{|sd| trace.include?(sd) ? [] : sd.manager.subordinate_requests(trace + [sd]) + sd.manager.new_hire_requests}.flatten.uniq
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

  def careers_roles
    roles.join('<br />')
  end

  def user_departments
    (self.managed_departments + self.supervised_departments + self.departments).uniq.collect{|d| d.to_s}.join("<br />")
  end

  def supervisors
    self.managed_departments.collect{|md| md.supervisor.to_s}.join("<br />")
  end

  def is_enabled
    enabled ? 'Yes' : 'No'
  end

  def enabled
    !inactive?
  end

  def self.edittable_attributes
    %w(notification_time new_hire_expiration)
  end

  def self.indexed_attributes
    %w(first_name last_name is_enabled careers_roles user_departments supervisors email new_hire_expiration notification_time last_notified)
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
