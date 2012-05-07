class RemoteUser < ActiveRecord::Base
  ROLES = %w(administrator email_administrator)

  def self.with_role(role)
    User.where(['roles_mask & ? > 0', 2**ROLES.index(role.to_s)]).all
  end

  def roles=(roles)
    roles.reject!{|r| !r.match(/^survey/i)}
    roles = roles.collect{|r| r.gsub(/^survey_/, '')}
    self.roles_mask = (roles & ROLES).map {|r| 2**ROLES.index(r)}.sum
  end

  def roles
    ROLES.reject{ |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero?}
  end

  def has_role?(role)
    self.roles.include?(role.to_s)
  end
end