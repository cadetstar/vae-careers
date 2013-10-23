class NewHireApproval < ActiveRecord::Base
  belongs_to :new_hire_request
  belongs_to :remote_user

  after_create :send_email_to_supervisor

  def send_email_to_supervisor
    if self.remote_user.try(:email) == I18n.t('admins.coo.email')
      Department.find_by_short_name('HUMRESC').remote_users.each do |ru|      
        GeneralMailer.central_mail(ru, "Request originally submitted by #{self.new_hire_request.creator}", "A new hire request has been approved by #{I18n.t('admins.coo.name')}.").deliver
      end
    else
      if (su = self.remote_user.supervisor_tree[0])
        GeneralMailer.central_mail(su, "Request originally submitted by #{self.new_hire_request.creator}", "A new hire request has been approved by #{self.remote_user}").deliver
      end
    end
  end
end
