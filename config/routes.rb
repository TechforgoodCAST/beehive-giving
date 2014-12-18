Rails.application.routes.draw do
  resources :organisations do
    resources :profiles
  end
end
