class NewHireApproval < ActiveRecord::Base
  belongs_to :new_hire_request
  belongs_to :remote_user
end
