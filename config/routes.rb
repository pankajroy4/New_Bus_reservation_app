require "sidekiq/web"

Rails.application.routes.draw do
  root "homes#index"
  get "admin_show/:id", to: "admins#show", as: :admin_show

  devise_scope :user do
    get "/admin_login", to: "users/sessions#new"
    get "/otp_verification", to: "users/confirmations#otp_verification", as: :verify
    patch "/verification", to: "users/sessions#otp_verification", as: :verify_login
    patch "/resend_otp", to: "users/sessions#resend_otp", as: :resend_otp
  end

  devise_for :users, controllers: {
                       registrations: "users/registrations",
                       sessions: "users/sessions",
                       passwords: "users/passwords",
                       confirmations: "users/confirmations",
                     }

  resources :users, only: [:show, :index]

  resources :bus_owners do
    resources :buses
  end

  resources :buses, only: [] do
    resources :reservations, only: [:new, :create, :index, :destroy]
  end

  get "/searched_bus", to: "homes#search", as: :search
  get "/bookings/:user_id", to: "reservations#booking", as: :bookings
  get "/get_resv_list/:bus_id", to: "buses#reservations_list", as: :get_resv_list
  patch "approve/:user_id/:id", to: "admins#approve", as: :approve
  patch "disapprove/:user_id/:id", to: "admins#disapprove", as: :disapprove

  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"
  end

  # match "*not_found", to: "homes#not_found", via: :all
end