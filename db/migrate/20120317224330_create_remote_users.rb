class CreateRemoteUsers < ActiveRecord::Migration
  def change
    create_table :remote_users do |t|
      t.string :first_name
      t.string :last_name
      t.integer :roles_mask
      t.string :email

      t.timestamps
    end
  end
end
