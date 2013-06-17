class AddDriverCheckAndPostingOptionsToNewHireRequests < ActiveRecord::Migration
  def change
    add_column :new_hire_requests, :driver_check, :boolean

    add_column :new_hire_requests, :posting_options, :string

  end
end
