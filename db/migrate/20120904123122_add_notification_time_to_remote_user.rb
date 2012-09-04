class AddNotificationTimeToRemoteUser < ActiveRecord::Migration
  def change
    add_column :remote_users, :notification_time, :integer

  end
end
