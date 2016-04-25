require 'high_voltage'

Rails.application.routes.draw do
  resources :uploads, :image_actions, :optimizes, :watermarks, only: [:new, :create]
  root to: 'high_voltage/pages#show', id: 'home'
end
