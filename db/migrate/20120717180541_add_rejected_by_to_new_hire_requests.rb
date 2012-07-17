class AddRejectedByToNewHireRequests < ActiveRecord::Migration
  def change
    add_column :new_hire_requests, :rejected_by, :integer

  end
end
