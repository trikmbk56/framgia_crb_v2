Rails.application.routes.draw do
  root "calendars#index"
  devise_for :users
  resources :calendars

  resources :users, only: :show do
    resources :calendars do
      resource :destroy_events, only: :destroy
    end
    resources :events, except: [:index] do
      resources :attendees, only: :destroy
    end
  end
  resources :attendees
  resources :events, except: :index
  resources :particular_calendars, only: :show
  get "auth/:provider/callback", to: "google_calendars#create"

  namespace :api do
    resources :calendars, only: [:update, :new]
    resources :users, only: :index
    resources :events, except: [:edit, :new]
    resources :request_emails, only: :new
    resources :particular_events, only: [:index, :show]
  end
end
