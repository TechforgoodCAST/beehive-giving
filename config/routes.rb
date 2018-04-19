Rails.application.routes.draw do
  resources :articles, only: %i[index show]
  resources :feedback, except: %i[show index destroy] # TODO: remove
  resources :password_resets, except: %i[show index destroy]
  resources :proposals, except: %i[show destroy]
  resources :reveals, only: :create
  resources :requests, only: :create

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
  get '/account-suspended', to: 'legacy#funder',     as: 'legacy_funder'
  get '/account-outdated',  to: 'legacy#fundraiser', as: 'legacy_fundraiser'
  get '/preview/:tag', to: redirect { |params, _request|
    "/#{params[:tag]}/funds"
  }

  # Sessions
  get  '/logout',  to: 'sessions#destroy'
  get  '/sign-in', to: 'sessions#new', as: 'sign_in'
  post '/sign-in', to: 'sessions#create'

  # Pages
  get '/faq',          to: 'pages#faq',     as: 'faq'
  get '/privacy',      to: 'pages#privacy', as: 'privacy'
  get '/terms',        to: 'pages#terms',   as: 'terms'
  get '/for-funders',  to: 'pages#forfunders', as: 'for_funders'

  # Sign up
  root 'signup/basics#new'
  post '/', to: 'signup/basics#create'

  namespace :signup do
    # get  '/basics', to: 'basics#new', as: 'basics'
    # post '/basics', to: 'basics#create'

    get  '/suitability', to: 'suitability#new', as: 'suitability'
    post '/suitability', to: 'suitability#create'
  end

  # User authorisation for organisational access
  match '/unauthorised', to: 'signup#unauthorised', via: :get, as: 'unauthorised'
  match '/grant_access/(:unlock_token)', to: 'signup#grant_access', via: :get, as: 'grant_access'
  match '/granted_access/(:unlock_token)', to: 'signup#granted_access', via: :get, as: 'granted_access'

  # Account
  post  '/agree/:id',                to: 'users#agree', as: 'agree'
  get   '/account',                  to: 'users#edit', as: 'account'
  patch '/account',                  to: 'users#update'
  get   '/account/:id',              to: 'recipients#edit', as: 'account_organisation'
  patch '/account/:id',              to: 'recipients#update'
  get   '/account/:id/subscription', to: 'accounts#subscription', as: 'account_subscription'
  get   '/account/:id/subscription/upgrade',   to: 'charges#new', as: 'account_upgrade'
  post  '/account/:id/subscription/upgrade',   to: 'charges#create'
  get   '/account/:id/subscription/thank-you', to: 'charges#thank_you', as: 'thank_you'

  # Funds
  get '/funds/(:proposal_id)',        to: 'funds#index',  as: 'funds'
  get '/fund/:id/(:proposal_id)',     to: 'funds#show',   as: 'fund'
  get '/h/fund/:id/(:proposal_id)',   to: 'funds#hidden', as: 'hidden'
  get '/:theme/funds/(:proposal_id)', to: 'funds#themed', as: 'theme'

  # Eligibilities
  patch '/fund/:id/:proposal_id/eligibility', to: 'eligibilities#create', as: 'eligibility'

  # Enquiries
  get  '/fund/:id/:proposal_id/apply', to: 'enquiries#new', as: 'apply'
  post '/fund/:id/:proposal_id/apply', to: 'enquiries#create'

  # Microsite
  get  '/check/:slug',                   to: 'microsites#basics', as: 'microsite_basics'
  post '/check/:slug',                   to: 'microsites#check_basics'
  get  '/check/:slug/eligibility/(:id)', to: 'microsites#eligibility', as: 'microsite_eligibility'
  post '/check/:slug/eligibility/:id',   to: 'microsites#check_eligibility'
  get  '/check/:slug/pre-results/(:id)', to: 'microsites#pre_results', as: 'microsite_pre_results'
  post '/check/:slug/pre-results/:id',   to: 'microsites#check_pre_results'
  get  '/check/:slug/results/:id',       to: 'microsites#results', as: 'microsite_results'

  # Webhooks
  post '/webhooks/invoice-payment-succeeded',     to: 'webhooks#invoice_payment_succeeded'
  post '/webhooks/customer-subscription-deleted', to: 'webhooks#customer_subscription_deleted'
end
