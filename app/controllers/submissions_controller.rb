class SubmissionsController < ApplicationController
  before_filter :authenticate_applicant!, :only => [:begin_application, :complete_application]
  before_filter :get_resource, :only => [:show, :notify_others]
  before_filter :is_current_user?, :except => [:begin_application, :complete_application]

  layout :choose_layout

  def begin_application
    unless (@opening = Opening.find_by_id(params[:opening_id]))
      flash[:alert] = 'I cannot find an opening with that identifier.'
      redirect_to root_path
      return
    end
    unless @opening.active
      flash[:alert] = 'That opening is no longer available.'
      redirect_to root_path
      return
    end
    @submission = Submission.find_or_create_by_opening_id_and_applicant_id(@opening.id, current_applicant.id)
    if @submission.completed?
      flash[:alert] = "You have already applied for this position.  If you wish to request information regarding your application, please contact #{t('admins.primary.name')} at #{t('admins.primary.email')}"
      redirect_to root_path
      return
    end
    if flash[:alert]
      @retrying = true
    end
  end

  def complete_application
    unless (@submission = Submission.find_by_id(params[:submission_id]))
      flash[:alert] = 'I could not find an application with that ID.'
      redirect_to root_path
      return
    end

    @submission.update_attributes(params[:submission])

    puts @submission.incomplete_notices.inspect

    if @submission.completed?
      flash[:notice] = 'Thank you for applying.  You should receive a confirmation email in a few minutes.'
      redirect_to root_path
    else
      flash[:alert] = "You still have a few things to complete before your application can be completed:<ul>#{@submission.incomplete_notices.collect{|a| "<li>#{a}</li>"}.join("")}</ul>"
      redirect_to apply_path(:opening_id => @submission.opening_id)
    end
  end

  def show

  end

  def retrieve_file
    if (file = ApplicantFile.find_by_id(params[:id]))
      #f = File.open(Rails.root.to_s + file.applicant_file_store.to_s)

      send_file Rails.root.to_s + file.applicant_file_store.to_s, :disposition => 'attachment', :filename => file[:applicant_file_store]
    else
      flash[:alert] = 'File not found.'
      redirect_to :back
    end
  end

  def generate_or_retrieve
    if (submission = Submission.find_by_id(params[:id]))
      result = submission.generate_paperwork(params[:type])
      send_file result, :type => 'application/zip', :disposition => 'attachment', :filename => "#{params[:generate_type] == 'pre' ? 'Pre-Employment' : 'Post-Hiring'} Paperwork - #{submission.applicant.name_lnf}.zip"
      #result.close
    else
      render :nothing => true
    end
  end

  def change_status
    if (@submission = Submission.find_by_id(params[:id]))
      status, result = @submission.change_status(params[:type])
      flash[status] = result
      redirect_to @submission
    else
      flash[:alert] = 'I could not find a submission with that ID.'
      redirect_to submissions_path
    end
  end

  def index
    session[:submissions] ||= {}
    session[:submissions][:name] ||= ''
    session[:submissions][:opening_id] ||= nil

    if params[:name]
      if session[:submissions][:name] != params[:name]
        params[:page] = 1
        session[:submissions][:name] = params[:name]
      end
    end

    if params[:opening_id]
      if session[:submissions][:opening_id] != params[:opening_id].to_i
        params[:page] = 1
        if params[:opening_id].to_i > 0
          session[:submissions][:opening_id] = params[:opening_id].to_i
        else
          session[:submissions][:opening_id] = nil
        end

      end
    end

    params[:page] ||= 1
    @resources = Submission.joins(:applicant, [:opening => :position]).where({:inactive => [nil, false]}).where(:completed => true).where(["LOWER(first_name) || ' ' || LOWER(last_name) like ?", "%#{session[:submissions][:name].downcase}%"])
    if session[:submissions][:opening_id]
      @resources = @resources.where(:opening_id => session[:submissions][:opening_id])
    end

    session[:submissions][:sort_order] ||= 'recruiter_recommendation, completed_at'
    if params[:sort_order]
      session[:submissions][:sort_order] = params[:sort_order]
    end
    @resources = @resources.order(session[:submissions][:sort_order]).page(params[:page]).includes([{:applicant => :tag_types}, {:opening => [:position, :department]}, :comments, :tag_types])
  end

  def update_recommendation
    if (@submission = Submission.find_by_id(params[:id]))
      @submission.recruiter_recommendation = params[:recruiter_recommendation]
      @submission.recruiter_comment = params[:recruiter_comment]
      @submission.save
    end
  end

  def notify_others
    succeeded = []
    failed = []
    params[:emails].each do |e|
      begin
        GeneralMailer.notify_email(e, params[:subject], params[:message]).deliver
        succeeded << e
      rescue
        failed << e
      end
    end
    flash[:notice] = "Notifications sent to #{succeeded.join(', ')}" unless succeeded.empty?
    flash[:alert] = "Notifications failed to send to #{failed.join(', ')}" unless failed.empty?
  end

  private

  def choose_layout
    case action_name
      when 'begin_application'
        'public'
      else
        'application'
    end
  end
end