Rails.application.routes.draw do
  resources :ads
  devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' }, controllers: { registrations: "registrations" }
  #devise_for :users
  resources :users
  resources :articles
  root 'ads#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
