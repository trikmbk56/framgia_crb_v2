Rails.application.routes.draw do
  root "static_pages#index"
  devise_for :users
  resources :users, only: :show do
    resources :calendars
  end
  resources :events, only: [:new, :create]
end
