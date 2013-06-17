class NewHireRequest < ActiveRecord::Base
  STATUSES = %w(Not\ Yet\ Submitted Posted Filled Submitted Held Rejected)

  belongs_to :position
  belongs_to :department
  belongs_to :creator, :class_name => "RemoteUser"

  belongs_to :opening

  belongs_to :rejector, :class_name => "RemoteUser", :foreign_key => "rejected_by"

  has_many :new_hire_approvals
  has_many :remote_users, :through => :new_hire_approvals, :order => "new_hire_approvals.created_at"

  has_many :new_hire_request_skills
  has_many :new_hire_skills, :through => :new_hire_request_skills

  default_scope where(:deleted => false)

  scope :direct, lambda {|user| where({:creator_id => user.id})}

  before_create {status = 'Not Yet Submitted'}

  def destroy
    self.update_attributes({:deleted => true})
    "#{self.to_s} destroyed."
  end

  def to_s
    "NHR - #{position} - #{department} by #{creator}"
  end

  def status
    STATUSES[self[:status] || 0]
  end

  def status=(val)
    self[:status] = STATUSES.index(val)
  end

  def change_status(new_status, user, prompt)
    case new_status
      when 'post'
        if user.has_role?('administrator')
          self.update_attributes(:status => "Posted")
          opening = Opening.create(:position => self.position, :department => self.department, :description => self.position.description)
          GeneralMailer.central_mail(self.creator, "An opening has been created for #{self}: #{prompt}", "An opening has been created for a new hire request").deliver
          ["An opening has been created from that request.", nil, opening]
        else
          [nil, "You do not have permission to do that.", nil]
        end
      when 'filled'
        if user.has_role?('administrator')
          self.update_attributes(:status => "Filled")
          ["New Hire Request has been marked as filled", nil, nil]
        else
          [nil, "You do not have permission to do that.", nil]
        end
      when 'disapprove'
        if self.remote_users.include? user
          if self.creator == user
            self.update_attributes(:status => "Not Yet Submitted")
          end
          GeneralMailer.central_mail(self.creator, "#{user} has removed their approval from #{self}: #{prompt}", "A user has removed their approval").deliver
          self.new_hire_approvals.find_by_remote_user_id(user.id).destroy
          ["Approval removed", nil, nil]
        else
          [nil, "You have not approved this request yet.", nil]
        end
      when 'approve'
        if self.remote_users.include? user
          [nil, "You have already approved this request.", nil]
        else
          if %w(Held Rejected).include? self.status
            if self.rejector == user or user.has_role?("administrator")
              self.update_attributes(:rejector => nil, :status => "Submitted")
              GeneralMailer.central_mail(self.creator, "#{user} has approved #{self}: #{prompt}", "A user has approved a new hire request.").deliver
              self.new_hire_approvals.create(:remote_user_id => user.id)
              ["Request approved.", nil, nil]
            else
              [nil, "That request is currently #{self.status.downcase}, contact #{self.requestor} to correct the status.", nil]
            end
          else
            if user == self.creator
              self.update_attributes(:status => "Submitted")
            else
              GeneralMailer.central_mail(self.creator, "#{user} has approved #{self}: #{prompt}", "A user has approved a new hire request.").deliver
            end
            self.new_hire_approvals.create(:remote_user_id => user.id)
            ["Request approved.", nil, nil]
          end
        end
      when 'hold'
        self.update_attributes(:status => "Held", :rejector => user)
        message = <<-TEXT
<p>Your request for #{self.position} created on #{self.created_at} has been placed on hold by #{user}:</p>
<p>"#{prompt}"</p>
<p>You can go to %URL% to correct the issue.</p>
        TEXT
        url = "edit_new_hire_request_path(:id => #{self.id})"
        GeneralMailer.central_mail(self.creator, message, "New Hire Request has been put on hold", url).deliver
      when 'reject'
        self.update_attributes(:status => "Rejected", :rejector => user)
        message = <<-REJECT
<p>Your request for #{self.position} created on #{self.created_at} has been rejected by #{user}:</p>
<p>"#{prompt}"</p>
        REJECT
        GeneralMailer.central_mail(self.creator, message, "New Hire Request has been rejected").deliver
    end
  end

  def position_description
    position.try(:description)
  end
end
