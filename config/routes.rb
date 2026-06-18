Rails.application.routes.draw do
  # get "reading_entries/index"
  # get "reading_entries/create"
  # get "reading_entries/update"
  # get "reading_entries/destroy"

  resource :session
  resources :passwords, param: :token
  resource :registration, only: [ :new, :create ]
  resources :books

  resources :reading_entries, only: [ :create, :update, :destroy ]
  get "library", to: "reading_entries#index"
  root "sessions#new"
end
