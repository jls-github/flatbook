Rails.application.routes.draw do
  resources :posts, only: [:index, :create]
  resources :users, only: [:index, :create]
  post "/login", to: "sessions#create"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
