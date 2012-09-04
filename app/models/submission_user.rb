class SubmissionUser < ActiveRecord::Base
  belongs_to :submission
  belongs_to :remote_user

  after_create :do_notification

  def do_notification
    if self.remote_user
      if self.remote_user.last_notified.nil? or self.remote_user.last_notified < self.remote_user.notification_time.to_i.days.ago
        GeneralMailer.submission_add(self.remote_user, self.submission).deliver
        self.remote_user.update_attribute(:last_notified, Time.now)
      end
    end
  end
end
