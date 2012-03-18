class Department < ActiveRecord::Base
  belongs_to :manager, :class_name => 'RemoteUser'
  belongs_to :supervisor, :class_name => 'RemoteUser'
  belongs_to :supervising_department, :class_name => 'Department'

  def self.list_for_select
    Department.all.collect{|d| [d, d.id]}
  end

  def to_s
    [code, name].compact.join(' - ')
  end
end
