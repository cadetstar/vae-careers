class Applicants::RegistrationsController < Devise::RegistrationsController
  before_filter :authenticate_applicant!, :only => [:edit, :update, :profile, :profile_update]
  before_filter :is_administrator?, :only => [:index, :view]
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

    if params[:name]
      session[:applicants][:name] = params[:name]
    end

    params[:page] ||= 1
    @resources = Applicant.order('last_name, first_name').where(["LOWER(first_name) || ' ' || LOWER(last_name) like ? or LOWER(email) like ?", "%#{session[:applicants][:name].downcase}%", "%#{session[:applicants][:name].downcase}%"]).page(params[:page])
    @klass = Applicant
    @suppress_new = true
  end

  def view
    unless (@resource = Applicant.find_by_id(params[:id]))
      flash[:alert] = "I could not find an applicant with that ID."
      redirect_to :action => :index
    end
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