class Applicants::RegistrationsController < Devise::RegistrationsController
  before_filter :authenticate_applicant!, :only => [:edit, :update, :profile, :profile_update]
  skip_before_filter :get_resource
  layout 'layouts/public'

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
end