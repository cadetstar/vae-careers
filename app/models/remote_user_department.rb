class RemoteUserDepartment < ActiveRecord::Base
  belongs_to :remote_user
  belongs_to :department
end
