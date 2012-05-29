class TagsController < ApplicationController
  before_filter :is_administrator?

  def update_tags
    klass = params[:resource_class].constantize
    if (resource = klass.find_by_id(params[:resource_id]))
      Tag.update_tags(resource, params[:tags], @current_user)
    end

    render :nothing => true
  end

  def destroy

  end
end