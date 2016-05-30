require 'high_voltage'

Rails.application.routes.draw do
  resources :image_actions, :optimizes, :watermarks, only: [:new, :create]
  resources :uploads, only: [:new, :create]
  get 'uploads/export' => 'uploads#export'
  get 'uploads/download' => 'uploads#download'
  root to: 'high_voltage/pages#show', id: 'home'
end