class CommentsController < ApplicationController
  before_filter :is_administrator?, :except => :create

  def create
    @comment = Comment.create(params[:comment])
  end

  def edit

  end

  def destroy
    @owner = @resource.owner
    flash[:notice] = @resource.destroy
    redirect_to @owner
  end
end