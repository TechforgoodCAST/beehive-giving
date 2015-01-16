Rails.application.routes.draw do
  root :to => 'sessions#check'
  get '/login' => 'sessions#new', as: 'login'
  post '/login' => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  match 'get-matched', to: 'users#new', via: :get, as: 'sign_up'

  match '/sign-up/user', to: 'signup#user', via: :get, as: 'signup_user'
  match '/sign-up/organisation', to: 'signup#organisation', via: :get, as: 'signup_organisation'
  match '/sign-up/profile', to: 'signup#profile', via: :get, as: 'signup_profile'
  match '/sign-up/comparison', to: 'signup#comparison', via: :get, as: 'signup_comparison'

  match '/sign-up/user', to: 'signup#create_user', via: :post
  match '/sign-up/organisation', to: 'signup#create_organisation', via: :post
  match '/sign-up/profile', to: 'signup#create_profile', via: :post

  # get '/:id' => 'organisations#show', as: 'organisation'

  resources :users
  resources :organisations do
    resources :profiles
    resources :grants
  end
  resources :password_resets
end
