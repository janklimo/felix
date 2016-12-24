Rails.application.routes.draw do
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
