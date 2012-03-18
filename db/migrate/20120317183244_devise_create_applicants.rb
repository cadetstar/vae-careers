class DeviseCreateApplicants < ActiveRecord::Migration
  def self.up
    create_table(:applicants) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable


      t.timestamps
    end

    add_index :applicants, :email,                :unique => true
    add_index :applicants, :reset_password_token, :unique => true
    # add_index :applicants, :confirmation_token,   :unique => true
    # add_index :applicants, :unlock_token,         :unique => true
    # add_index :applicants, :authentication_token, :unique => true
  end

  def self.down
    drop_table :applicants
  end
end
