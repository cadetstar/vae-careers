class AddOpeningIdToNewHireRequests < ActiveRecord::Migration
  def change
    add_column :new_hire_requests, :opening_id, :integer

  end
end
