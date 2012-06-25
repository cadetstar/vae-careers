class SubmissionsController < ApplicationController
  before_filter :authenticate_applicant!, :only => [:begin_application, :complete_application]
  before_filter :get_resource, :only => [:show]
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

  end

  def generate_or_retrieve
    if (submission = Submission.find_by_id(params[:id]))
      result = submission.generate_paperwork(params[:type])
      send_file result.path, :type => 'application/zip', :disposition => 'attachment', :filename => "#{params[:generate_type] == 'pre' ? 'Pre-Employment' : 'Post-Hiring'} Paperwork - #{submission.applicant.name_lnf}.zip"
      result.close
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
    @resources = Submission.where(:completed => true).order("recruiter_recommendation nulls first, created_at")
  end

  def update_recommendation
    if (@submission = Submission.find_by_id(params[:id]))
      @submission.recruiter_recommendation = params[:recommendation]
      @submission.save
    end
    render :nothing => true
  end

  def choose_layout
    case action_name
      when 'begin_application'
        'public'
      else
        'application'
    end
  end
end