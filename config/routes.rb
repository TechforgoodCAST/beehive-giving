Rails.application.routes.draw do
  get '/' => redirect('/login')
  get '/login' => 'sessions#new', as: 'login'
  post '/login' => 'sessions#create'

  resources :organisations do
    resources :profiles
  end
end
