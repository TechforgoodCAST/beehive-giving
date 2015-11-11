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
  get '/logout'  => 'sessions#destroy'
  match '/sign-in', to: 'sessions#new', via: :get, as: 'sign_in'
  match '/sign-in', to: 'sessions#create', via: :post

  # Pages
  match '/tour', to: 'pages#tour', via: :get, as: 'tour'
  match '/about', to: 'pages#about', via: :get, as: 'about'
  match '/privacy', to: 'pages#privacy', via: :get, as: 'privacy'
  match '/terms', to: 'pages#terms', via: :get, as: 'terms'

  # Sign up
  match '/welcome', to: 'signup#user', via: :get, as: 'signup_user'
  match '/welcome', to: 'signup#create_user', via: :post

  match '/your-organisation', to: 'signup#organisation', via: :get, as: 'signup_organisation'
  match '/your-organisation', to: 'signup#create_organisation', via: :post

  match '/new-funder', to: 'signup#funder', via: :get, as: 'new_funder'
  match '/new-funder', to: 'signup#create_funder', via: :post

  # Funders
  match '/funders/recommended', to: 'recipients#recommended_funders', via: :get, as: 'recommended_funders'
  match '/funders/eligible', to: 'recipients#eligible_funders', via: :get, as: 'eligible_funders'
  match '/funders/ineligible', to: 'recipients#ineligible_funders', via: :get, as: 'ineligible_funders'
  match '/funders', to: 'recipients#all_funders', via: :get, as: 'all_funders'

  # Recipients
  match '/organisation/(:id)', to: 'recipients#show', via: :get, as: 'recipient_public'
  # match '/(:id)/edit', to: 'recipients#edit', via: :get, as: 'recipient_edit'
  # match '/(:id)/edit', to: 'recipients#edit', via: :patch

  # Eligibilities
  match '/eligibility/(:id)', to: 'recipients#eligibility', via: :get, as: 'recipient_eligibility'
  match '/eligibility/(:id)', to: 'recipients#update_eligibility', via: :patch
  match '/(:id)/eligibility', to: 'recipients#eligibilities', via: :get, as: 'recipient_eligibilities'
  match '/(:id)/eligibility', to: 'recipients#update_eligibilities', via: :patch

  # Enquiries
  match '/comparison/(:id)/apply', to: 'enquiries#apply', via: :post, as: 'recipient_apply'

  # Compare funders
  match '/funders/comparison', to: 'funders#comparison', via: :get, as: 'funders_comparison'

  resources :users
  resources :feedback, :only => [:new, :create]
  resources :password_resets, :only => [:new, :create, :edit, :update]

  resources :recipients, :except => [:new, :index] do
    member do
      post :vote
      post :approach_funder
    end
    resources :profiles, :only => [:new, :create, :index, :edit, :update]
    resources :recipient_attribute, :as => :attribute, :only => [:new, :create, :edit, :update]
  end

  resources :funders, :except =>[:edit, :update] do
    member do
      get :explore
      get :eligible
    end
    resources :grants, :except =>[:show]
  end

end
