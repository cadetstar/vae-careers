class AddPermDataFieldsToApplicants < ActiveRecord::Migration
  def change
    add_column :applicants, :first_name, :string
    add_column :applicants, :last_name, :string
    add_column :applicants, :preferred_name, :string
    add_column :applicants, :address_1, :string
    add_column :applicants, :address_2, :string
    add_column :applicants, :city, :string
    add_column :applicants, :state, :string
    add_column :applicants, :zip, :string
    add_column :applicants, :country, :string
  end
end
