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
      flash[:alert] = 'You are unable to do that.'
      redirect_to root_path
    end
  end

  def after_sign_in_path_for(resource)
    if session[:return_to]
      session[:return_to]
    else
      super
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
    frags = params[:frags] || []
    values = params[:values] || []

    unless params[:suppress_rc].to_i == 1
      frags << params[:resource_class].underscore + '_id'
      values << params[:id]
    end
    full_frags = frags.clone
    if params[:link_class].constantize.attribute_names.include?("#{params[:source_name]}_type")
      full_frags << "#{params[:source_name]}_type"
    end
    full_frags << "#{params[:source_name]}_id"

    params[:items] ||= {}
    puts params[:items].inspect
    params[:items].each do |k, v|
      v.each_with_index do |qg_id,i|
        if (qg = k.constantize.find_by_id(qg_id))
          if params[:link_class].constantize.attribute_names.include?("#{params[:source_name]}_type")
            ogc = params[:link_class].constantize.send("find_or_create_by_#{full_frags.join('_and_')}", *values, qg.class.name, qg.id)
          else
            ogc = params[:link_class].constantize.send("find_or_create_by_#{full_frags.join('_and_')}", *values, qg.id)
          end
          ogc.group_order = i + 1 if ogc.respond_to?(:group_order)
          ogc.save
        end
      end
    end
    if params[:link_class].constantize.attribute_names.include?("#{params[:source_name]}_type")
      params[:link_class].constantize.where([frags.collect{|f| "#{f} = ?"}.join(' and '), *values]).each do |obj|
        parent = obj.send(params[:source_name])
        puts obj.inspect
        obj.destroy unless (!params[:items][parent.class.name].nil? and params[:items][parent.class.name].include?(parent.id.to_s))
      end
    else
      params[:link_class].constantize.where(["#{frags.collect{|f| "#{f} = ?"}.join(' and ')} and #{params[:source_name]}_id not in (?)", *values, (!params[:items].empty? ? params[:items].collect{|k,v| v}.flatten : [-1])]).each do |old_qg|
        old_qg.destroy
      end
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
