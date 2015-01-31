Rails.application.routes.draw do
  root :to => 'sessions#check'
  get '/login' => 'sessions#new', as: 'login'
  post '/login' => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  # Pages
  match 'tour', to: 'pages#tour', via: :get, as: 'tour'

  # Sign up
  match '/welcome', to: 'signup#user', via: :get, as: 'signup_user'
  match '/your-organisation', to: 'signup#organisation', via: :get, as: 'signup_organisation'
  match '/your-profile', to: 'signup#profile', via: :get, as: 'signup_profile'
  match '/dashboard', to: 'recipients#dashboard', via: :get, as: 'signup_comparison'

  match '/comparison/(:id)', to: 'recipients#comparison', via: :get, as: 'recipient_comparison'

  match '/new-funder', to: 'signup#funder', via: :get, as: 'new_funder'

  match '/welcome', to: 'signup#create_user', via: :post
  match '/your-organisation', to: 'signup#create_organisation', via: :post
  match '/your-profile', to: 'signup#create_profile', via: :post

  match '/new-funder', to: 'signup#create_funder', via: :post

  resources :users
  resources :organisations, :funders, :recipients do
    resources :profiles
    resources :grants
  end
  resources :password_resets
end
