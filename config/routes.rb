Rails.application.routes.draw do

  # Errors
  %w( 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

  # Admin
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Sessions
  root :to => 'sessions#check'
  get '/login' => 'sessions#new', as: 'login'
  post '/login' => 'sessions#create'
  get '/logout'  => 'sessions#destroy'

  # Pages
  match '/tour', to: 'pages#tour', via: :get, as: 'tour'
  match '/about', to: 'pages#about', via: :get, as: 'about'
  match '/privacy', to: 'pages#privacy', via: :get, as: 'privacy'
  match '/terms', to: 'pages#terms', via: :get, as: 'terms'

  # Sign up
  match '/welcome', to: 'signup#user', via: :get, as: 'signup_user'
  match '/find', to: 'signup#find', via: :get, as: 'find'
  match '/your-organisation', to: 'signup#organisation', via: :get, as: 'signup_organisation'
  match '/your-profile', to: 'signup#profile', via: :get, as: 'signup_profile'

  match '/welcome', to: 'signup#create_user', via: :post
  match '/find', to: 'signup#find', via: :post
  match '/your-organisation', to: 'signup#create_organisation', via: :post
  match '/your-profile', to: 'signup#create_profile', via: :post

  match '/new-funder', to: 'signup#funder', via: :get, as: 'new_funder'
  match '/new-funder', to: 'signup#create_funder', via: :post

  # RecipientDashboard
  match '/comparison/(:id)/gateway', to: 'recipients#gateway', via: :get, as: 'recipient_comparison_gateway'
  match '/comparison/(:id)/unlock_funder', to: 'recipients#unlock_funder', via: :post, as: 'recipient_unlock_funder'
  match '/comparison/(:id)', to: 'recipients#comparison', via: :get, as: 'recipient_comparison'
  match '/organisation/(:id)', to: 'recipients#show', via: :get, as: 'recipient_public'
  # match '/(:id)/edit', to: 'recipients#edit', via: :get, as: 'recipient_edit'
  # match '/(:id)/edit', to: 'recipients#edit', via: :patch

  # Eligibility
  match '/eligibility/(:funder_id)', to: 'recipients#eligibility', via: :get, as: 'recipient_eligibility'
  match '/eligibility/(:funder_id)', to: 'recipients#update_eligibility', via: :patch
  match '/(:id)/eligibility', to: 'recipients#eligibilities', via: :get, as: 'recipient_eligibilities'
  match '/(:id)/eligibility', to: 'recipients#update_eligibilities', via: :patch

  # Enquiries
  match '/comparison/(:id)/approach_funder', to: 'enquiries#approach_funder', via: :post, as: 'recipient_approach_funder'
  match '/comparison/(:id)/feedback', to: 'recommendations#edit', via: :get, as: 'recipient_recommendation_feedback'
  match '/comparison/(:id)/feedback', to: 'recommendations#update', via: :patch
  match '/comparison/(:id)/apply', to: 'enquiries#apply', via: :post, as: 'recipient_apply'
  match '/comparison/(:id)/guidance', to: 'enquiries#guidance', via: :post, as: 'recipient_guidance'

  # Compare funders
  match '/funders/comparison', to: 'funders#comparison', via: :get, as: 'funders_comparison'

  resources :users
  resources :feedback, :only => [:new, :create]
  resources :password_resets, :only => [:new, :create, :edit, :update]

  resources :recipients do
    member do
      post :vote
      post :approach_funder
    end
    resources :profiles, :only => [:new, :create, :index, :edit, :update]
    resources :recipient_attribute, :as => :attribute, :only => [:new, :create, :edit, :update]
  end

  resources :funders do
    member do
      get :explore
    end
    resources :grants
  end

end
