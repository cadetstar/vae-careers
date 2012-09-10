class RemoteUsersController < ApplicationController
  before_filter :is_current_user?
  skip_before_filter :get_resource

  def index
    @resources = RemoteUser.unscoped.includes(:departments, :managed_departments, :supervised_departments).order('inactive, last_name, first_name')
    @suppress_delete = true
  end

  def edit
    if current_user.has_role?('administrator')
      get_resource
    else
      @resource = current_user
    end
  end

  def update
    if current_user.has_role?('administrator')
      get_resource
      if @resource
        @resource.update_attributes(params[:remote_user])
      end
      redirect_to :action => :index
    else
      @resource = current_user
      @resource.update_attributes(params[:remote_user])
      redirect_to submissions_path
    end
  end
end