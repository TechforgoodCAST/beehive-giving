Rails.application.routes.draw do
  resources :articles, only: [:index, :show]
  resources :password_resets, except: [:show, :index, :destroy]

  get '/funds', to: 'public_funds#index', as: 'public_funds'
  get '/funds/:slug', to: 'public_funds#show', as: 'public_fund'
  get '/funds/theme/:theme', to: 'public_funds#themed', as: 'public_funds_theme'

  resources :proposals, except: [:show, :destroy] do
    resources :funds, only: [:show, :index] do
      collection do
        get '/theme/:theme', to: 'funds#themed', as: 'theme'
      end
      member do
        get   :eligibility, to: 'eligibilities#new'
        patch :eligibility, to: 'eligibilities#create'
        get   :apply,       to: 'enquiries#new'
        post  :apply,       to: 'enquiries#create'
      end
    end
  end

  get '/proposals/:id/funds?eligibility=eligible', to: 'funds#index', as: 'eligible_proposal_funds'
  get '/proposals/:id/funds?eligibility=ineligible', to: 'funds#index', as: 'ineligible_proposal_funds'

  resources :feedback, except: [:show, :index, :destroy]

  # Errors
  match '/404', to: 'errors#not_found', via: :all
  match '/410', to: 'errors#gone', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  # Admin
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Legacy support
  get '/about',   to: 'pages#about', as: 'about'
  get '/tour',    to: redirect('/')
  get '/welcome', to: redirect('/')
  get '/files/Data&ResearchLead.pdf', to: redirect('410')

  # Sessions
  get  '/logout',  to: 'sessions#destroy'
  get  '/sign-in', to: 'sessions#new', as: 'sign_in'
  post '/sign-in', to: 'sessions#create'

  # Pages
  get '/faq',          to: 'pages#faq',     as: 'faq'
  get '/privacy',      to: 'pages#privacy', as: 'privacy'
  get '/terms',        to: 'pages#terms',   as: 'terms'
  get '/preview/:tag', to: 'pages#preview', as: 'preview'
  get '/for-funders',  to: 'pages#forfunders', as: 'for_funders'

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
end
