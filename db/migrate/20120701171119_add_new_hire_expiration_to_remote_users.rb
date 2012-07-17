class AddNewHireExpirationToRemoteUsers < ActiveRecord::Migration
  def change
    add_column :remote_users, :new_hire_expiration, :integer

  end
end
