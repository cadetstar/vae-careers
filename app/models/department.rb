class Department < ActiveRecord::Base
  belongs_to :manager, :class_name => 'RemoteUser'
  belongs_to :supervisor, :class_name => 'RemoteUser'
  belongs_to :supervising_department, :class_name => 'Department'

  has_many :openings

  def self.list_for_select
    Department.order("code").all.collect{|d| [d, d.id]}
  end

  def self.states_with_departments
    Department.select("distinct departments.state").order("departments.state").where(["state not in (?)", ['USA', 'CAN']]).all.collect{|c| c.state}
  end

  def city_state
    [city, state].compact.join(', ')
  end

  def to_s
    [code, name].compact.join(' - ')
  end
end
