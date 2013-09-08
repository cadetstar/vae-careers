class Applicants::RegistrationsController < Devise::RegistrationsController
  before_filter :authenticate_applicant!, :only => [:edit, :update, :profile, :profile_update]
  before_filter :is_administrator?, :only => [:index, :view, :send_email_to_filtered_users]
  skip_before_filter :get_resource
  layout :choose_layout

  def destroy
    flash[:alert] = 'That is not permitted.'
    redirect_to root_path
  end

  def profile
    @applicant = current_applicant
  end

  def profile_update
    @applicant = current_applicant
    @applicant.update_attributes(params[:applicant], :as => :applicant)
    redirect_to root_path
  end

  def index
    session[:applicants] ||= {}
    session[:applicants][:name] ||= ''
    session[:applicants][:tags] ||= []

    if params[:name]
      session[:applicants][:name] = params[:name]
    end

    if params[:tags]
      session[:applicants][:tags] = params[:tags]
    end

    if session[:applicants][:tags] == ['0']
      session[:applicants][:tags] = []
    end

    params[:page] ||= 1
    session[:applicants][:sort_order] ||= 'last_name, first_name'
    if params[:sort_order]
      session[:applicants][:sort_order] = params[:sort_order]
    end

    get_applicants_with_filters

    @resources = @resources.page(params[:page])
    @klass = Applicant
    @suppress_new = true
  end

  def get_applicants_with_filters
    @resources = Applicant.joins("left join tags on (applicants.id = tags.owner_id and tags.owner_type = 'Applicant')").order(session[:applicants][:sort_order]).where(["LOWER(first_name) || ' ' || LOWER(last_name) like ? or LOWER(email) like ?", "%#{session[:applicants][:name].downcase}%", "%#{session[:applicants][:name].downcase}%"])
    if !session[:applicants][:tags].empty?
      @resources = @resources.where(['tags.tag_type_id in (?)', session[:applicants][:tags]])
    end
  end

  def view
    unless (@resource = Applicant.find_by_id(params[:id]))
      flash[:alert] = "I could not find an applicant with that ID."
      redirect_to applicants_path
    end
  end

  def send_email
    get_applicants_with_filters
  end

  def send_email_to_given_users
    succeeded = []
    failed = []

    @resources = Applicant.find_all_by_email(params[:emails])

    @resources.each do |r|
      begin
        GeneralMailer.notify_email(r.email, params[:subject], params[:message]).deliver
        succeeded << r.email
      rescue
        failed << r.email
      end
    end
    flash[:notice] = "Notifications sent to #{succeeded.join(', ')}" unless succeeded.empty?
    flash[:alert] = "Notifications failed to send to #{failed.join(', ')}" unless failed.empty?
    redirect_to applicants_path
  end

  def send_email_to_filtered_users
    get_applicants_with_filters
    succeeded = []
    failed = []

    @resources.each do |r|
      begin
        GeneralMailer.notify_email(r.email, params[:subject], params[:message]).deliver
        succeeded << r.email
      rescue
        failed << r.email
      end
    end
    flash[:notice] = "Notifications sent to #{succeeded.join(', ')}" unless succeeded.empty?
    flash[:alert] = "Notifications failed to send to #{failed.join(', ')}" unless failed.empty?
    redirect_to applicants_path
  end

  def custom_destroy
    if (@resource = Applicant.find_by_id(params[:id]))
      flash[:notice] = @resource.destroy
    else
      flash[:alert] = "I could not find an applicant with that ID."
    end
    redirect_to applicants_path
  end

  private

  def choose_layout
    case action_name
      when 'view', 'index'
        'application'
      else
        'public'
    end
  end
end