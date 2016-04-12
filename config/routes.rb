Rails.application.routes.draw do

  resources :users, only: :show
  root "static_pages#index"
  devise_for :users
end
