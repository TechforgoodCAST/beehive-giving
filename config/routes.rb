Rails.application.routes.draw do
  # Errors
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  # Admin
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Legacy support
  get '/about',   to: redirect('/')
  get '/tour',    to: redirect('#tell-me-more')
  get '/welcome', to: redirect('/')

  # Sessions
  get  '/logout',  to: 'sessions#destroy'
  get  '/sign-in', to: 'sessions#new', as: 'sign_in'
  post '/sign-in', to: 'sessions#create'

  # Pages
  get '/faq',     to: 'pages#faq',     as: 'faq'
  get '/privacy', to: 'pages#privacy', as: 'privacy'
  get '/terms',   to: 'pages#terms',   as: 'terms'

  # Sign up
  root 'signup#user'
  post '/', to: 'signup#create_user'

  get   '/basics',       to: 'signup#organisation', as: 'signup_organisation'
  post  '/basics',       to: 'signup#create_organisation'
  get   '/(:id)/basics', to: 'recipients#edit', as: 'edit_recipient'
  patch '/(:id)/basics', to: 'recipients#update'

  get  '/proposal',       to: 'signup_proposals#new', as: 'new_signup_proposal'
  post '/proposal',       to: 'signup_proposals#create'
  get  '/proposal/(:id)', to: 'signup_proposals#edit', as: 'edit_signup_proposal'
  post '/proposal/(:id)', to: 'signup_proposals#update'

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

  resources :proposals, except: [:show, :destroy] do
    resources :funds, only: :show do
      collection do
        get :recommended
        get :eligible
        get :ineligible
        get :all
        get '/theme/:tag', to: 'funds#tagged', as: 'tag'
      end
      member do
        get   :eligibility, to: 'eligibilities#new'
        patch :eligibility, to: 'eligibilities#create'
        get   :apply,       to: 'enquiries#new'
        post  :apply,       to: 'enquiries#create'
      end
    end
  end

  # Funders
  # NOTE: deprecated
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

  resources :feedback, only: [:new, :create, :edit, :update]
  resources :password_resets, only: [:new, :create, :edit, :update]

  resources :recipients, except: [:new, :index] do
    member do
      post :approach_funder
    end
  end
end
