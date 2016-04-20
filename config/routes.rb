Rails.application.routes.draw do

  root "static_pages#index"
  devise_for :users
  resources :users, only: :show do
    resources :calendars do
      resource :destroy_events, only: :destroy
    end
    resources :events, except: :index
  end

  namespace :api do
    resources :events, only: [:index, :destroy, :update]
  end
end
