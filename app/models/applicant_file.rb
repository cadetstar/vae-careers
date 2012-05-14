class ApplicantFile < ActiveRecord::Base
  belongs_to :applicant
  belongs_to :submission

  mount_uploader :applicant_file_store, ApplicantFileStoreUploader

  def applicant_file_store=(val)
    if !val.is_a?(String) && valid?
      applicant_file_store_will_change!
      super
    else
      super
    end
  end
end
