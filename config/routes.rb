Rails.application.routes.draw do
  resources :password_resets, except: [:show, :index, :destroy]

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

  resources :feedback, except: [:show, :index, :destroy]

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

  get   '/basics',       to: 'signup_recipients#new', as: 'new_signup_recipient'
  post  '/basics',       to: 'signup_recipients#create'
  get   '/basics/(:id)', to: 'signup_recipients#edit', as: 'edit_signup_recipient'
  patch '/basics/(:id)', to: 'signup_recipients#update'

  get   '/proposal',       to: 'signup_proposals#new', as: 'new_signup_proposal'
  post  '/proposal',       to: 'signup_proposals#create'
  get   '/proposal/(:id)', to: 'signup_proposals#edit', as: 'edit_signup_proposal'
  patch '/proposal/(:id)', to: 'signup_proposals#update'

  # User authorisation for organisational access
  match '/unauthorised', to: 'signup#unauthorised', via: :get, as: 'unauthorised'
  match '/grant_access/(:unlock_token)', to: 'signup#grant_access', via: :get, as: 'grant_access'
  match '/granted_access/(:unlock_token)', to: 'signup#granted_access', via: :get, as: 'granted_access'

  # Account
  get   '/account',                  to: 'users#edit', as: 'account'
  patch '/account',                  to: 'users#update'
  get   '/account/:id',              to: 'recipients#edit', as: 'account_organisation'
  patch '/account/:id',              to: 'recipients#update'
  get   '/account/:id/subscription', to: 'accounts#subscription', as: 'account_subscription'
  get   '/account/:id/subscription/upgrade',   to: 'charges#new', as: 'account_upgrade'
  post  '/account/:id/subscription/upgrade',   to: 'charges#create'
  get   '/account/:id/subscription/thank-you', to: 'charges#thank_you', as: 'thank_you'

  # Webhooks
  post '/webhooks/invoice-payment-succeeded',     to: 'webhooks#invoice_payment_succeeded'
  post '/webhooks/customer-subscription-deleted', to: 'webhooks#customer_subscription_deleted'

  # Funders
  # NOTE: deprecated
  match '/funding/(:id)/overview', to: 'funders#overview', via: :get, as: 'funder_overview'
  match '/funding/(:id)/map', to: 'funders#map', via: :get, as: 'funder_map'
  match '/map-data/(:id)', to: 'funders#map_data', via: :get, as: 'funder_map_data'
  match '/map-data/all', to: 'funders#map_data', via: :get, as: 'funders_map_all'
  match '/funding/(:id)/(:district)', to: 'funders#district', via: :get, as: 'funder_district'
end
