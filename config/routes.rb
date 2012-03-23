VaeCareers::Application.routes.draw do

  match 'applicants/profile', :to => 'applicants/registrations#profile', :as => 'profile'
  match 'applicants/profile/update', :to => 'applicants/registrations#profile_update', :as => 'profile_update'

  devise_for :applicants, :controllers => {:sessions => 'applicants/sessions', :registrations => 'applicants/registrations'}


  match 'question_groups/question_orders/:id', :to => 'question_groups#set_question_groups', :as => 'set_question_groups'
  match 'openings/question_group_orders/:id', :to => 'openings#set_question_groups', :as => 'set_opening_groups'
  match 'openings/:id/change_status', :to => 'openings#change_status', :as => 'change_opening_status'


  root :to => 'openings#public'
  match 'user/internal', :to => redirect('/position_types'), :as => 'internal_user'
  match '/', :as => 'applicant_root_path'
  match 'from_accounts/return', :to => 'application#from_accounts', :as => 'from_accounts'
  match 'logout', :to => 'application#universal_sign_out', :as => 'logout'
  match 'start_query', :to => 'departments#start_query'
  match 'openings/description/:id', :to => 'openings#get_description'

  resources :position_types
  resources :positions
  resources :questions
  resources :question_groups
  resources :openings
end
