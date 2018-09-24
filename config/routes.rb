# TODO: refactor
Rails.application.routes.draw do
  resources :articles, only: %i[index show]
  resources :feedback, except: %i[show index destroy] # TODO: remove
  resources :reveals, only: :create # TODO: remove
  resources :requests, only: :create # TODO: remove

  ## v3 start ##

  root 'pages#home'

  get  '/check/:slug', to: 'recipients#new', as: 'new_recipient'
  post '/check/:slug', to: 'recipients#create'

  get  '/check/:slug/proposal/:hashid', to: 'proposals#new', as: 'new_proposal'
  post '/check/:slug/proposal/:hashid', to: 'proposals#create'

  get  '/reports/:proposal_id/upgrade', to: 'charges#new', as: 'new_charge'
  post '/reports/:proposal_id/upgrade', to: 'charges#create'
  # TODO: thank you page?

  get '/reports/:proposal_id', to: 'reports#show', as: 'report'
  get '/reports', to: 'reports#index', as: 'reports'

  namespace :sign_in, path: 'sign-in' do
    get  '/', to: 'lookup#new', as: 'lookup'
    post '/', to: 'lookup#create'

    get  '/auth', to: 'auth#new', as: 'auth'
    post '/auth', to: 'auth#create'

    get  '/reset', to: 'reset#new', as: 'reset'
    post '/reset', to: 'reset#create'

    get  '/set/:token', to: 'set#new', as: 'set'
    post '/set/:token', to: 'set#create'
  end

  get '/sign-out',  to: 'sign_in/auth#destroy', as: 'sign_out'

  namespace :api do
    namespace :v1 do
      get '/districts/:country_id', to: 'districts#index', as: 'districts'
    end
  end

  ## v3 end ##

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
  get '/account-suspended',    to: 'legacy#funder',     as: 'legacy_funder'
  get '/account-outdated',     to: 'legacy#fundraiser', as: 'legacy_fundraiser'
  get '/account-outdated/:id', to: 'legacy#reset',      as: 'legacy_reset'
  get '/preview/:tag', to: redirect { |params, _request|
    "/#{params[:tag]}/funds"
  }

  # Pages
  get '/faq',          to: 'pages#faq',     as: 'faq'
  get '/privacy',      to: 'pages#privacy', as: 'privacy'
  get '/terms',        to: 'pages#terms',   as: 'terms'
  get '/for-funders',  to: 'pages#forfunders', as: 'for_funders'

  # Account
  post  '/agree/:id',                to: 'users#agree', as: 'agree'
  get   '/account',                  to: 'users#edit', as: 'account'
  patch '/account',                  to: 'users#update'
  get   '/account/:id',              to: 'recipients#edit', as: 'account_organisation'
  patch '/account/:id',              to: 'recipients#update'
  get   '/account/:id/subscription', to: 'accounts#subscription', as: 'account_subscription'

  get '/proposals/:id', to: 'proposals#edit'

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

  # Misc.
  get '/cookies/update', to: 'cookies#update', as: 'update_cookies'
end
