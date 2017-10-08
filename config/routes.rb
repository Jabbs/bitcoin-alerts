Rails.application.routes.draw do
  resources :users do
    resources :verifications, only: [:show]
  end
  controller :sessions do
    post 'login' => :create
    delete 'logout' => :destroy
  end
  resources :channels do
    resources :subscriptions
    post 'show_modal'
  end
  root 'channels#index'
  resources :quotes, only: [:index]
  resources :trades, only: [:index]
  resources :simulations, only: [:index]
  resources :order_books, only: [:index]
  resources :order_book_items, only: [:index]
  resources :bittrex_market_summaries, only: [:index]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :poloniex_quotes, only: [:index]
  resources :charts, only: [:index]
  match '/charts/:exchange/:currency_pair', to: "charts#show", via: :get
  match '/login',                           to: 'onboarding#login', via: :get
  match '/signup',                          to: 'onboarding#signup', via: :get
  match '/password_reset',                  to: 'onboarding#password_reset', via: :get
  match '/privacy',                         to: 'static_pages#privacy', via: :get
  match '/terms',                           to: 'static_pages#terms', via: :get
end
