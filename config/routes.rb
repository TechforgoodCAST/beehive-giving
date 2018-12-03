# TODO: refactor
Rails.application.routes.draw do
  resources :articles, only: %i[index show]

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

  get '/opportunities', to: 'opportunities#index', as: 'opportunities'
  get '/opportunities/:slug/reports', to: 'opportunities#show', as: 'opportunity'

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

  get '/sign-out', to: 'sign_in/auth#destroy', as: 'sign_out'

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

  # Pages
  get '/about', to: redirect('/articles/about'), as: 'about'
  get '/add-an-opportunity', to: 'pages#add_opportunity', as: 'add_opportunity'
  get '/faq', to: redirect('/articles/faq'), as: 'faq'
  get '/opportunity-providers', to: redirect('/articles/opportunity-providers'), as: 'opportunity_providers'
  get '/pricing', to: 'pages#pricing', as: 'pricing'
  get '/privacy', to: 'pages#privacy', as: 'privacy'
  get '/terms', to: 'pages#terms', as: 'terms'

  # Misc.
  post '/agree-to-terms/:id', to: 'users#terms_version', as: 'terms_version'
  post '/acknowledge-update/:id', to: 'users#update_version', as: 'update_version'
  get  '/cookies/update', to: 'cookies#update', as: 'update_cookies'

  # Legacy
  get '/:slug/funds', to: redirect('/opportunities')
  get '/for-funders', to: redirect('/faq')
  get '/fund/:slug', to: redirect('/opportunities')
  get '/funds', to: redirect('/opportunities')
  get '/funds/:slug', to: redirect('/opportunities')
  get '/funds/theme/:slug', to: redirect('/opportunities')
  get '/password_resets/new', to: redirect('/sign-in')
  get '/welcome', to: redirect('/')
end
