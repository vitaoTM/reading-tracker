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
  get "want_to_read", to: "reading_entries#want_to_read"
  post "want_to_read/import_amazon", to: "reading_entries#import_amazon", as: :import_amazon
  post "want_to_read/import_csv", to: "reading_entries#import_csv", as: :import_csv

  root "sessions#new"
end
