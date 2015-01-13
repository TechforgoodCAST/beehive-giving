Rails.application.routes.draw do
  root 'sessions#new'
  get '/login' => 'sessions#new', as: 'login'
  post '/login' => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  match 'get-matched', to: 'users#new', via: :get, as: 'sign_up'

  # get '/:id' => 'organisations#show', as: 'organisation'

  resources :users
  resources :organisations do
    resources :profiles
    resources :grants
  end
  resources :password_resets
end
