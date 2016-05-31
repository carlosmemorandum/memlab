require 'high_voltage'

Rails.application.routes.draw do
  resources :image_actions, :optimizes, :watermarks, :uploads, only: [:new, :create]
  get 'uploads/export' => 'uploads#export'
  get 'uploads/download' => 'uploads#download'
  get 'optimizes/export' => 'optimizes#export'
  get 'optimizes/download' => 'optimizes#download'
  get 'watermarks/export' => 'watermarks#export'
  get 'watermarks/download' => 'watermarks#download'
  root to: 'high_voltage/pages#show', id: 'home'
end