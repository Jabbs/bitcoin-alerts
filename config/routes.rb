Rails.application.routes.draw do
  root 'welcome#index'
  resources :quotes, only: [:index]
  resources :trades, only: [:index]
  resources :simulations, only: [:index]
  resources :order_books, only: [:index]
  resources :order_book_items, only: [:index]
end
