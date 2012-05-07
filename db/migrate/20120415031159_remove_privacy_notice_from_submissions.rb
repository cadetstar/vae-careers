class RemovePrivacyNoticeFromSubmissions < ActiveRecord::Migration
  def up
    remove_column :submissions, :privacy_notice
  end

  def down
    add_column :submissions, :privacy_notice, :boolean
  end
end
