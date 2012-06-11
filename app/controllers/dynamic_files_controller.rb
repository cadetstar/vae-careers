class DynamicFilesController < ApplicationController
  before_filter :is_administrator?

  def update
    files_size = @resource.dynamic_file_revisions.size
    @resource.update_attributes(params[controller_name.singularize.to_sym])
    flash[:notice] = "#{controller_name.singularize.titleize} updated."
    if @resource.dynamic_file_revisions.reload.size > files_size
      redirect_to :action => :edit
    else
      redirect_to :action => :index
    end
  end
end