VaeCareers::Application.routes.draw do

  devise_for :applicants, :controllers => {:sessions => 'applicants/sessions'}

  resources :position_types
  resources :positions
  resources :questions
  resources :question_groups


  root :to => 'openings#public'
  match '/user/internal', :to => redirect('/position_types'), :as => 'internal_user'
  match '/from_accounts/return', :to => 'application#from_accounts', :as => 'from_accounts'
  match 'logout', :to => 'application#universal_sign_out', :as => 'logout'
  match 'start_query', :to => 'departments#start_query'
end
