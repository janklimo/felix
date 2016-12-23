Rails.application.routes.draw do
  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
    registrations: 'admins/registrations',
    confirmations: 'admins/confirmations',
    passwords: 'admins/passwords'
  }
  root to: "home#index"

  namespace :admin do
    get :home
  end
end
