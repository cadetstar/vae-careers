class SubmissionAnswer < ActiveRecord::Base
  belongs_to :submission
  belongs_to :question

  delegate :applicant, :to => :submission

  scope :reports, joins({:submission => [:opening, :applicant]}, :question)

  REPORT_FIELD_OVERRIDES = {
      'id' => false,
      'created_at' => false,
      'updated_at' => false,
      'applicant' => true
  }

  OVERRIDE_METHOD = {

  }

end
