class ApplicationController < ActionController::Base
  require 'digest'
  require 'base64'
  require 'openssl'
  require 'net/http'
  require 'uri'
  before_filter :get_resource, :only => [:edit, :update, :destroy]

  protect_from_forgery


  def is_administrator?
    unless current_user and current_user.has_role?('administrator')
      redirect_to root_path
    end
  end

  def prevent_current_user
    if current_user
      redirect_to internal_user_path
    end
  end

  def current_user
    @current_user ||= RemoteUser.find_by_id(session[:current_user])
  end

  # These are generic methods that can be overwritten inside the individual controllers

  def index
    klass = controller_name.classify.constantize
    @resources = klass.all
  end

  def new
    @resource = controller_name.classify.constantize.create
    redirect_to :action => :edit, :id => @resource.id
  end

  def edit

  end

  def update
    @resource.update_attributes(params[controller_name.singularize.to_sym])
    flash[:notice] = "#{controller_name.singularize.titleize} updated."
    redirect_to :action => :index
  end

  def destroy
    flash[:notice] = @resource.destroy
    redirect_to :action => :index
  end

  def get_resource
    unless @resource = controller_name.classify.constantize.find_by_id(params[:id])
      if request.xhr?
        render :nothing => true
      else
        flash[:alert] = "I could not find a #{controller_name.singularize.titleize} with that ID."
        redirect_to :action => :index
      end
    end
  end
end
