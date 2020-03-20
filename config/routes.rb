Rails.application.routes.draw do
  scope "(:locale)" do
    resources :ads
    devise_for :users, path: "", path_names: { sign_in: "login", sign_out: "logout", sign_up: "register" }, controllers: { registrations: "registrations" }
    resources :users
    resources :articles
    resources :currencies, only: [:index, :show]
    root "ads#index"
    post "ads/save_currency", to: "ads#save_currency"
  end
end
