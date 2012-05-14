class SubmissionsController < ApplicationController
  before_filter :authenticate_applicant!, :only => [:begin_application, :complete_application]
  before_filter :get_resource, :only => [:show]

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
  end

  def complete_application
    unless (@submission = Submission.find_by_id(params[:submission_id]))
      flash[:alert] = 'I could not find an application with that ID.'
      redirect_to root_path
      return
    end

    @submission.update_attributes(params[:submission])

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

  def choose_layout
    case action_name
      when 'begin_application'
        'public'
      else
        'application'
    end
  end
end