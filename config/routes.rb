Rails.application.routes.draw do
  resources :posts
  resources :servers
  get 'settings', to: 'settings#index'
  put 'settings', to: 'settings#update'

  root to: 'dashboard#index'
end
