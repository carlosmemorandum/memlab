require 'high_voltage'

Rails.application.routes.draw do
  resources :uploads, only: [:new, :create]
  resources :optimizes, only: [:new, :create]
  root to: 'high_voltage/pages#show', id: 'home'
end
