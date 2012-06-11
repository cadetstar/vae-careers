class ApplicationController < ActionController::Base
  require 'digest'
  require 'base64'
  require 'openssl'
  require 'net/http'
  require 'uri'
  before_filter :get_resource, :only => [:edit, :update, :destroy]

  protect_from_forgery

  rescue_from Exception, :with => :my_log_error
  rescue_from ActiveRecord::RecordNotFound, :with => :my_log_error
  rescue_from ActionController::UnknownController, :with => :my_log_error
  rescue_from ::AbstractController::ActionNotFound, :with => :my_log_error


  def is_administrator?
    unless current_user and current_user.has_role?('administrator')
      redirect_to root_path
    end
  end

  def prevent_current_user
    if current_user
      redirect_to '/user/internal'
    end
  end

  def is_current_user?
    unless current_user
      redirect_to root_path
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

  def generic_reordering
    rc_frag = params[:resource_class].underscore + '_id'
    qg_frag = params[:source_class].underscore + '_id'
    (params[:items] || []).each_with_index do |qg_id,i|
      if qg = params[:source_class].constantize.find_by_id(qg_id)
        ogc = params[:link_class].constantize.send("find_or_create_by_#{rc_frag}_and_#{qg_frag}".to_sym, params[:id], qg.id)
        ogc.group_order = i + 1 if ogc.respond_to?(:group_order)
        ogc.save
      end
    end
    params[:link_class].constantize.where(["#{rc_frag} = ? and #{qg_frag} not in (?)", params[:id], (params[:items] || [-1])]).each do |old_qg|
      old_qg.destroy
    end
    render :text => ''
  end

  def make_pdf(output_file, input_files)
    `gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=#{output_file} #{input_files.join(' ')}`
  end

  private

  def my_log_error(exception)
    Rails.logger.error exception
    Rails.logger.error exception.backtrace.join('\n')

    #(([exception] + ActiveSupport::BacktraceCleaner.new.clean(exception.backtrace)).join('\r\n'))
    GeneralMailer.error_message(exception,
                               ActiveSupport::BacktraceCleaner.new.clean(exception.backtrace),
                               session.instance_variable_get("@data"),
                               params,
                               request.env,
                               current_user || current_applicant,
                               request.env['HTTP_HOST'].match(/careers2\.vaecorp\.com/)
    ).deliver

    #redirect_to '/500.html'
    render :file => "public/500.html", :layout => false, :status => 500
  end
end
