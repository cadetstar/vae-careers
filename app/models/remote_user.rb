class RemoteUser < ActiveRecord::Base
  has_many :comments, :as => :creator
  has_many :tags, :as => :creator

  ROLES = %w(administrator email_administrator)

  def to_s
    [first_name, last_name].compact.join(' ')
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

  private

  def method_missing(name, *args)
    if name.match(/\?$/) and ROLES.include?(name.to_s.gsub(/\?$/, ''))
      self.has_role?(name.to_s.gsub(/\?$/, ''))
    else
      super
    end
  end
end
