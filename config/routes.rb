Rails.application.routes.draw do
  root 'welcome#index'
  resources :quotes, only: [:index]
  resources :trades, only: [:index]
  resources :simulations, only: [:index]
  resources :order_books, only: [:index]
  resources :order_book_items, only: [:index]
  resources :bittrex_market_summaries, only: [:index]
  resources :poloniex_quotes, only: [:index]
  resources :charts, only: [:index]
  match '/charts/:exchange/:currency_pair', to: "charts#show", via: :get
end
