class RemoteUsersController < ApplicationController
  before_filter :is_current_user?
  before_filter :is_administrator?, :only => :bulk_submissions_modify
  skip_before_filter :get_resource
  before_filter :get_resource, :only => :bulk_submissions_modify

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

  def bulk_submissions_modify
    case params[:type].to_s.downcase
      when 'remove'
        flash[:notice] = "Removed #{@resource.submissions.count} submissions from #{@resource}."
        @resource.submissions = []
        @resource.save
      when 'copy'
        if (new_user = RemoteUser.find_by_id(params[:new_user_id]))
          flash[:notice] = "Added #{(@resource.submissions - new_user.submissions).count} submissions to #{new_user}."
          new_user.submissions += (@resource.submissions - new_user.submissions)
          new_user.save
        else
          flash[:alert] = 'You must choose the user to copy all permissions to.'
        end
      else
        flash[:alert] = 'That is not a valid command.'
    end
    redirect_to edit_remote_user_path(:id => @resource.id)
  end
end