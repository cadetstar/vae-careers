class ApplicantFile < ActiveRecord::Base
  belongs_to :applicant
  belongs_to :submission

  mount_uploader :applicant_file_store, ApplicantFileStoreUploader
end
