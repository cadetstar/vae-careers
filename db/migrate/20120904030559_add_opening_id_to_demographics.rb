class AddOpeningIdToDemographics < ActiveRecord::Migration
  def change
    add_column :demographics, :opening_id, :integer
  end
end
