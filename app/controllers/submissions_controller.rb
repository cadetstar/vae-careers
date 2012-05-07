class SubmissionsController < ApplicationController
  before_filter :authenticate_applicant!, :only => [:begin_application]

  layout :choose_layout

  def begin_application
    unless @opening = Opening.find_by_id(params[:opening_id])
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
    unless (@submission = Submission.find_by_id(params[:id]))
      flash[:alert] = 'I could not find an application with that ID.'
      redirect_to root_path
      return
    end

    @submission.update_attributes(params[:submission])



    puts params.inspect
  end

  def choose_layout
    case action_name
      when 'begin_application'
        'public'
    end
  end
end