# config/routes.rb
Rails.application.routes.draw do
  # --- Authentication routes ---
  post "login", to: "sessions#create"
  post "signup", to: "users#create"
  delete "logout", to: "sessions#destroy"

  # Posts, comments, likes, admin routes
  resources :posts do
    resources :comments, only: [ :create ]
    post "like", to: "likes#create"
    delete "like", to: "likes#destroy"
  end

  # --- Admin namespace ---
  namespace :admin do
    resources :comments, only: [ :index ] do
      member do
        patch  :approve
        delete :reject
      end
    end
  end

  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check

  # Root path
  root "posts#index"
end
