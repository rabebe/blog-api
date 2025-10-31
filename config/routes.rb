Rails.application.routes.draw do
  # --- Authentication routes ---
  # Login route
  post "login", to: "sessions#create"

  # Logout route
  delete "logout", to: "sessions#destroy"


  resources :posts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.

  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
