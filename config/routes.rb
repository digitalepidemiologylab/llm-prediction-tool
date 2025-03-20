# frozen_string_literal: true

Rails.application.routes.draw do
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "home#index"

  devise_for :users

  resources :datasets, only: %i[index show new create] do
    resources :experiments, only: %i[new create], controller: "datasets/experiments"
  end
  resources :experiments, only: %i[show] do
    resources :results, only: %i[create], controller: "experiments/results"
  end
  resources :results, only: [] do
    resource :data, only: %i[show], controller: "results/data"
    resource :cancellations, only: %i[create], controller: "results/cancellations"
  end

  namespace :admin do
    mount LetterOpenerWeb::Engine, at: "/emails" if Rails.env.development?

    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
end
