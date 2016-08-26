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
  match '/faq', to: 'pages#faq', via: :get, as: 'faq'

  # Sign up
  match '/welcome', to: 'signup#user', via: :get, as: 'signup_user'
  match '/welcome', to: 'signup#create_user', via: :post

  match '/basics', to: 'signup#organisation', via: :get, as: 'signup_organisation'
  match '/basics', to: 'signup#create_organisation', via: :post

  match '/(:id)/basics', to: 'recipients#edit', via: :get, as: 'edit_recipient'
  match '/(:id)/basics', to: 'recipients#update', via: :patch

  match '/new-funder', to: 'signup#funder', via: :get, as: 'new_funder'
  match '/new-funder', to: 'signup#create_funder', via: :post

  # User authorisation for organisational access
  match '/unauthorised', to: 'signup#unauthorised', via: :get, as: 'unauthorised'
  match '/grant_access/(:unlock_token)', to: 'signup#grant_access', via: :get, as: 'grant_access'
  match '/granted_access/(:unlock_token)', to: 'signup#granted_access', via: :get, as: 'granted_access'

  # Account
  # match '/account', to: 'accounts#user', via: :get, as: 'account'
  # match '/account/(:id)', to: 'accounts#organisation', via: :get, as: 'account_organisation'
  match '/account/(:id)/subscription', to: 'accounts#subscription', via: :get, as: 'account_subscription'
  match '/account/(:id)/upgrade', to: 'accounts#upgrade', via: :get, as: 'account_upgrade'
  match '/account/(:id)/charge', to: 'accounts#charge', via: :post, as: 'account_charge'

  # Funds
  match '/funds/home', to: 'funds#home', via: :get, as: 'funds_home'
  match '/funds/(:id)', to: 'funds#show', via: :get, as: 'fund'

  # Funders
  match '/funders/recommended', to: 'recipients#recommended_funders', via: :get, as: 'recommended_funders'
  match '/funders/eligible', to: 'recipients#eligible_funders', via: :get, as: 'eligible_funders'
  match '/funders/ineligible', to: 'recipients#ineligible_funders', via: :get, as: 'ineligible_funders'
  match '/funders', to: 'recipients#all_funders', via: :get, as: 'all_funders'
  get '/(:tag)/funders', to: 'funders#tagged', as: 'tag'

  # Recipients
  match '/organisation/(:id)', to: 'recipients#show', via: :get, as: 'recipient_public'
  match '/proposals/(:id)/recent', to: 'funders#recent', via: :get, as: 'funder_recent'

  match '/funding/(:id)/overview', to: 'funders#overview', via: :get, as: 'funder_overview'
  # match '/funding/(:id)/overview/(:year)', to: 'funders#overview', via: :get, as: 'funder_overview'

  match '/funding/(:id)/map', to: 'funders#map', via: :get, as: 'funder_map'
  # match '/funding/(:id)/map/(:year)', to: 'funders#map', via: :get, as: 'funder_map'
  match '/map-data/(:id)', to: 'funders#map_data', via: :get, as: 'funder_map_data'
  match '/map-data/all', to: 'funders#map_data', via: :get, as: 'funders_map_all'

  match '/funding/(:id)/(:district)', to: 'funders#district', via: :get, as: 'funder_district'
  # match '/funding/(:id)/(:district)/(:year)', to: 'funders#district', via: :get, as: 'funder_district'

  # Eligibilities
  match '/funders/(:id)/eligibility', to: 'recipients#eligibility', via: :get, as: 'recipient_eligibility'
  match '/funders/(:id)/eligibility', to: 'recipients#update_eligibility', via: :patch

  # Proposals
  match '/(:id)/proposal', to: 'proposals#new', via: :get, as: 'new_recipient_proposal'
  match '/(:id)/proposal', to: 'proposals#create', via: :post
  match '/(:recipient_id)/proposal/(:id)', to: 'proposals#edit', via: :get, as: 'edit_recipient_proposal'
  match '/(:recipient_id)/proposal/(:id)', to: 'proposals#update', via: :patch
  match '/(:recipient_id)/proposals', to: 'proposals#index', via: :get, as: 'recipient_proposals'

  # Enquiries
  match '/funders/(:id)/apply', to: 'recipients#apply', via: :get, as: 'recipient_apply'
  match '/funders/(:id)/apply', to: 'enquiries#apply', via: :post

  # Compare funders
  match '/funders/comparison', to: 'funders#comparison', via: :get, as: 'funders_comparison'

  resources :users
  resources :feedback, :only => [:new, :create, :edit, :update]
  resources :password_resets, :only => [:new, :create, :edit, :update]

  resources :recipients, :except => [:new, :index] do
    member do
      post :approach_funder
    end
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
