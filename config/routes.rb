Rails.application.routes.draw do
  resources :posts
  resources :servers
  get 'settings', to: 'settings#index'
  put 'settings', to: 'settings#update'

  post 'dashboard/api_update', to: 'dashboard#api_update'

  root to: 'dashboard#index'
end
