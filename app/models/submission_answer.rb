class SubmissionAnswer < ActiveRecord::Base
  belongs_to :submission
  belongs_to :question

end
