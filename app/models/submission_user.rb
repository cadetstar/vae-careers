class SubmissionUser < ActiveRecord::Base
  belongs_to :submission
  belongs_to :remote_user

  after_create :do_notification
  after_create :add_supervisors

  validates_uniqueness_of :remote_user_id, :scope => :submission_id

  def do_notification
    if self.remote_user
      if self.remote_user.last_notified.nil? or self.remote_user.last_notified < self.remote_user.notification_time.to_i.days.ago
        GeneralMailer.submission_add(self.remote_user, self.submission).deliver
        self.remote_user.update_attribute(:last_notified, Time.now)
      end
    end
  end

  def add_supervisors
    if self.remote_user and self.submission
      self.remote_user.supervisor_tree.each do |s|
        if s != self.remote_user
          self.submission.submission_users.find_or_create_by_remote_user_id(s.id)
        end
      end
    end
  end
end
