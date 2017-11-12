require 'sidekiq/web'
Rails.application.routes.draw do
  resources :verifications, only: [:show]
  resources :users do
    match '/resend_verification', to: "verifications#resend", via: :post
  end
  controller :sessions do
    post 'login' => :create
    delete 'logout' => :destroy
  end
  resources :channels do
    resources :rules, only: [:edit, :update]
    resources :subscriptions
    post 'show_modal'
  end
  resources :currencies, only: [:index]
  root 'channels#index'
  resources :quotes, only: [:index]
  resources :trades, only: [:index]
  resources :simulations, only: [:index]
  resources :order_books, only: [:index]
  resources :order_book_items, only: [:index]
  resources :bittrex_market_summaries, only: [:index]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :charts, only: [:index]
  match '/settings',                        to: "users#settings", via: :get
  match '/unsubscribe',                     to: "subscriptions#unsubscribe", via: :get
  match '/charts/:exchange/:currency_pair', to: "charts#show", via: :get
  match '/login',                           to: 'onboarding#login', via: :get
  match '/signup',                          to: 'onboarding#signup', via: :get
  match '/password_reset',                  to: 'onboarding#password_reset', via: :get
  match '/privacy',                         to: 'static_pages#privacy', via: :get
  match '/terms',                           to: 'static_pages#terms', via: :get
  mount Sidekiq::Web, at: '/sidekiq'
end
