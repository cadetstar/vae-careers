class ApplicationController < ActionController::Base
  require 'digest'
  require 'base64'
  require 'openssl'
  require 'net/http'
  require 'uri'
  before_filter :get_resource, :only => [:edit, :update, :destroy]

  protect_from_forgery

  def from_accounts

    begin
      private_key = OpenSSL::PKey::RSA.new(File.read('lib/keys/acct_remote'))
      b = Base64.decode64(params[:key].gsub(' ','+'))
      key = private_key.private_decrypt(b)
      public_key = OpenSSL::PKey::RSA.new(File.read('lib/keys/remote_acct.pem'))
      encrypted_key = Base64.encode64(public_key.public_encrypt(key))

      uri = URI.parse("http://localhost:3000/passkey/validate?id=#{params[:user]}&key=#{URI.escape(encrypted_key, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      user_info = JSON.parse(response.body)
      remote_user = RemoteUser.find_or_create_by_email(user_info['email'])
      remote_user.update_attributes(user_info.select{|k,v| k != 'id' and (RemoteUser.attribute_names.include?(k) or k == 'roles')})

      session[:current_user] = remote_user.id
      redirect_to internal_user_path
    rescue
      flash[:alert] = 'I could not log you in with those credentials.'
      redirect_to new_applicant_session_path
    end

  end

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

  def universal_sign_out
    session[:current_user] = nil
    sign_out
    redirect_to root_path
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
