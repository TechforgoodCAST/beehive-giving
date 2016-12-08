Rails.application.routes.draw do
  # Errors
  %w(404 422 500).each do |code|
    get code, to: 'errors#show', code: code
  end

  # Admin
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Sessions
  root to: 'sessions#check'
  get '/logout' => 'sessions#destroy'
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

  # User authorisation for organisational access
  match '/unauthorised', to: 'signup#unauthorised', via: :get, as: 'unauthorised'
  match '/grant_access/(:unlock_token)', to: 'signup#grant_access', via: :get, as: 'grant_access'
  match '/granted_access/(:unlock_token)', to: 'signup#granted_access', via: :get, as: 'granted_access'

  # Account
  # match '/account', to: 'accounts#user', via: :get, as: 'account'
  # match '/account/(:id)', to: 'accounts#organisation', via: :get, as: 'account_organisation'
  # TODO match '/account/(:id)/subscription', to: 'accounts#subscription', via: :get, as: 'account_subscription'
  # TODO match '/account/(:id)/upgrade', to: 'accounts#upgrade', via: :get, as: 'account_upgrade'
  # TODO match '/account/(:id)/charge', to: 'accounts#charge', via: :post, as: 'account_charge'

  # Funds
  match '/recommended/funds', to: 'recipients#recommended_funds', via: :get, as: 'recommended_funds'
  match '/eligible/funds', to: 'recipients#eligible_funds', via: :get, as: 'eligible_funds'
  match '/ineligible/funds', to: 'recipients#ineligible_funds', via: :get, as: 'ineligible_funds'
  match '/all/funds', to: 'recipients#all_funds', via: :get, as: 'all_funds'
  get '/(:tag)/funds', to: 'funds#tagged', as: 'tag'

  # Funders - deprecated
  match '/funding/(:id)/overview', to: 'funders#overview', via: :get, as: 'funder_overview'
  match '/funding/(:id)/map', to: 'funders#map', via: :get, as: 'funder_map'
  match '/map-data/(:id)', to: 'funders#map_data', via: :get, as: 'funder_map_data'
  match '/map-data/all', to: 'funders#map_data', via: :get, as: 'funders_map_all'
  match '/funding/(:id)/(:district)', to: 'funders#district', via: :get, as: 'funder_district'

  # Proposals
  match '/(:id)/proposal', to: 'proposals#new', via: :get, as: 'new_recipient_proposal'
  match '/(:id)/proposal', to: 'proposals#create', via: :post
  match '/(:recipient_id)/proposal/(:id)', to: 'proposals#edit', via: :get, as: 'edit_recipient_proposal'
  match '/(:recipient_id)/proposal/(:id)', to: 'proposals#update', via: :patch
  match '/(:recipient_id)/proposals', to: 'proposals#index', via: :get, as: 'recipient_proposals'

  # Eligibilities
  match '/funds/(:id)/eligibility', to: 'eligibilities#new', via: :get, as: 'fund_eligibility'
  match '/funds/(:id)/eligibility', to: 'eligibilities#create', via: :patch

  # Enquiries
  match '/funds/(:id)/apply', to: 'enquiries#new', via: :get, as: 'fund_apply'
  match '/funds/(:id)/apply', to: 'enquiries#create', via: :post

  resources :feedback, only: [:new, :create, :edit, :update]
  resources :password_resets, only: [:new, :create, :edit, :update]

  resources :recipients, except: [:new, :index] do
    member do
      post :approach_funder
    end
  end

  resources :funds, only: :show
end
