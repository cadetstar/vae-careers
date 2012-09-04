class Applicants::SessionsController < Devise::SessionsController
  before_filter :prevent_current_user
  layout 'layouts/public'

  def new
    session[:return_to] = params[:return_to] if params[:return_to]
    super
  end
end