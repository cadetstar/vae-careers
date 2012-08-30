class CommentsController < ApplicationController
  before_filter :is_administrator?, :except => :create
  before_filter :is_current_user?

  def create
    @comment = Comment.create(params[:comment].merge(:creator => current_user))
  end

  def edit

  end

  def destroy
    @owner = @resource.owner
    flash[:notice] = @resource.destroy
    redirect_to @owner
  end
end