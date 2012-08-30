VaeCareers::Application.routes.draw do
  devise_for :applicants, :controllers => {:sessions => 'applicants/sessions', :registrations => 'applicants/registrations'}
  devise_scope :applicant do
    match 'applicants/profile', :to => 'applicants/registrations#profile', :as => 'profile'
    match 'applicants/profile/update', :to => 'applicants/registrations#profile_update', :as => 'profile_update'
  end

  match 'question_groups/question_orders/:id', :to => 'question_groups#set_question_groups', :as => 'set_question_groups'
  match 'openings/:id/change_status', :to => 'openings#change_status', :as => 'change_opening_status'

  match 'submission/file/:id', :to => 'submissions#retrieve_file', :as => 'retrieve_application_file'

  root :to => 'openings#public'
  match 'openings/:id/view', :to => 'openings#view', :as => 'view_opening'
  match 'showpublic/:id', :to => redirect('/openings/%{id}/view') # Legacy route

  match 'openings/:opening_id/apply', :to => 'submissions#begin_application', :as => 'apply'
  match 'openings/:id/demographics', :to => 'openings#view_demographics', :as => 'demographics'
  match 'openings/:submission_id/submit', :to => 'submissions#complete_application', :as => 'submit_application'

  match '/applicant', :to => redirect('/'), :as => 'applicant_root_path'
  match 'from_accounts/return', :to => 'remote_sessions#from_accounts', :as => 'from_accounts'
  match 'logout', :to => 'remote_sessions#universal_sign_out', :as => 'logout'
  match 'start_query', :to => 'departments#start_query'
  match 'openings/description/:id', :to => 'openings#get_description'

  match 'submission/:id/setup', :to => 'submissions#setup', :as => 'submission_setup'
  match 'submission/:id/files/:type', :to => 'submissions#generate_or_retrieve', :as => 'paperwork'
  match 'submission/:id/recommendation', :to => 'submissions#update_recommendation'
  match 'submission/:id/status', :to => 'submissions#change_status', :as => 'change_status'
  match 'tags/:resource_class/:resource_id', :to => 'tags#update_tags', :as => 'update_tags'
  match 'openings/opp', :to => 'openings#open_positions_posting', :as => 'opp'
  match 'dynamic_files/:id/compile', :to => 'dynamic_files#test_compile', :as => 'test_file_compile'

  match 'new_hire_requests/status', :to => 'new_hire_requests#change_status', :as => 'change_nhr_status'

  match 'ordering/:resource_class/:id', :to => 'application#generic_reordering', :as => 'generic_reordering'

  match 'reports/:id/start', :to => 'reports#start_run', :as => "start_report"
  match 'reports/:id/execute', :to => 'reports#execute_report', :as => 'execute_report'
  match 'reports/:id/results', :to => 'reports#view_report', :as => 'view_results'

  resources :position_types
  resources :positions
  resources :questions
  resources :question_groups
  resources :openings
  resources :submissions
  resources :comments
  resources :static_texts
  resources :tag_types
  resources :dynamic_files
  resources :dynamic_form_groups
  resources :new_hire_requests
  resources :new_hire_skills
  resources :reports

  match 'user/internal', :to => redirect('/position_types')#, :as => 'internal_user'
end
