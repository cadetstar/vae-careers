class Department < ActiveRecord::Base
  belongs_to :manager, :class_name => 'RemoteUser'
  belongs_to :supervisor, :class_name => 'RemoteUser'
  belongs_to :supervising_department, :class_name => 'Department'

  def to_s
    [code, name].compact.join(' - ')
  end
end
