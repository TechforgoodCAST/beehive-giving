Rails.application.routes.draw do
  get '/' => redirect('/login')
  get '/login' => 'sessions#new', as: 'login'
  post '/login' => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  # get '/:id' => 'organisations#show', as: 'organisation'

  resources :organisations do
    resources :profiles
  end
end
