Rails.application.routes.draw do
  root "frontend_pages#map"

  # Test routes
  get "test/map", to: "test#map_test", as: "test_map"

  resource :session
  resources :passwords, param: :token
  resources :restaurants do
    resources :tacos
    resources :photos
    resources :reviews
    post "toggle_favorite", on: :member

    # Test route for map debugging
    get "map_test", on: :collection
  end
  resources :favorites, only: [ :index ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
