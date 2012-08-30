class AddSubmissionIdToDemographics < ActiveRecord::Migration
  def change
    add_column :demographics, :submissions_id, :integer

  end
end
