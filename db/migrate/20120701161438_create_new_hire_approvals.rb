class CreateNewHireApprovals < ActiveRecord::Migration
  def change
    create_table :new_hire_approvals do |t|
      t.integer :remote_user_id
      t.integer :new_hire_request_id

      t.timestamps
    end
  end
end
