class Applicants::SessionsController < Devise::SessionsController
  before_filter :prevent_current_user
  layout 'layouts/public'
end