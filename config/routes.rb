Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: [ :new, :create ]
  resources :books do
    resources :ratings, only: [ :create, :destroy ]
  end

  resources :reading_entries, only: [ :create, :update, :destroy ]
  get "library", to: "reading_entries#index"
  get "want_to_read", to: "reading_entries#want_to_read"
  post "want_to_read/import_amazon", to: "reading_entries#import_amazon", as: :import_amazon
  post "want_to_read/import_csv", to: "reading_entries#import_csv", as: :import_csv

  get "habits", to: "reading_sessions#index"
  resources :reading_sessions, only: [ :create, :destroy ]

  resources :favorite_books, only: [ :create, :destroy ] do
    collection { patch :reorder }
  end
  get "favorites", to: "favorite_books#index"

  resources :recommendation_lists do
    resources :recommendation_list_items, only: [ :create, :update, :destroy ]
  end
  get "lists", to: "recommendation_lists#discover"
  get "top_recommended", to: "books#top_recommended"

  resources :loans

  root "books#index"
end
