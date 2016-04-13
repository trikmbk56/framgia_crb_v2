Rails.application.routes.draw do

  root "static_pages#index"
  devise_for :users
  resources :users, only: :show
  resources :calendars
  resources :users, only: :show do
    resources :calendars
    resources :events, only: [:edit, :show]
  end
  resources :calendars, only: [:index, :new, :create]
  resources :events, except: [:index, :destroy]
end
