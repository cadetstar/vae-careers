class JobAgentsController < ApplicationController
  before_filter :authenticate_applicant!
  layout "public"

  def index
    @resources = current_applicant.job_agents
  end

  def new
    @resource = current_applicant.job_agents.create
    redirect_to edit_job_agent_path(@resource)
  end

  def get_resource
    unless (@resource = current_applicant.job_agents.find_by_id(params[:id]))
      flash[:alert] = 'I could not find that Job Agent'
      redirect_to root_path
    end
  end
end