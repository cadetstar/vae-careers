class AddInactiveToRemoteUsers < ActiveRecord::Migration
  def change
    add_column :remote_users, :inactive, :boolean

  end
end
