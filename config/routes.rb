Rails.application.routes.draw do
  root to: redirect("/dashboard")

  # Authentication
  get    "login",  to: "sessions#new",     as: :new_session
  post   "login",  to: "sessions#create",  as: :session
  delete "logout", to: "sessions#destroy", as: :logout

  # Password reset
  get   "forgot",       to: "passwords#new",    as: :new_password
  post  "forgot",       to: "passwords#create", as: :passwords
  get   "reset/:token", to: "passwords#edit",   as: :edit_password
  patch "reset/:token", to: "passwords#update", as: :password

  get "dashboard", to: "dashboard#show", as: :dashboard

  resources :domains, path: "ssl", only: %i[ index create destroy ]

  resources :tickets, only: %i[ index show create ] do
    post :reply, on: :member
  end

  get   "settings",          to: "settings#show",            as: :settings
  patch "settings/email",    to: "settings#update_email",    as: :settings_email
  patch "settings/password", to: "settings#update_password", as: :settings_password

  namespace :admin do
    root "dashboard#show"
    resources :clients, only: %i[ show create destroy ] do
      resources :monitors, only: %i[ create destroy ]
    end
  end

  # Health check for load balancers and uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check
end
