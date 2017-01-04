Rails.application.routes.draw do
  namespace :cms do
    resources :companies
    resources :metrics
    resources :options
    resources :questions
    resources :tokens
    resources :users

    root to: "companies#index"
  end

  root to: "home#index"

  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations',
    confirmations: 'admins/confirmations',
    passwords: 'admins/passwords'
  }

  namespace :admin do
    get :home
  end

  resources :companies, only: [:create, :update, :new, :edit]

  # endpoint to receive LINE callbacks
  post 'callback', to: 'bot#callback'
end
