class AddLastNotifiedToRemoteUser < ActiveRecord::Migration
  def change
    add_column :remote_users, :last_notified, :datetime

  end
end
