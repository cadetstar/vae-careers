class DynamicFileRevision < ActiveRecord::Base
  belongs_to :dynamic_file

  has_many :file_fields

  mount_uploader :dynamic_file_store, DynamicFileUploader
end
