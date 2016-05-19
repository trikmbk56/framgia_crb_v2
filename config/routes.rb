Rails.application.routes.draw do

  root "calendars#index"
  devise_for :users
  resources :users, only: :show do
    resources :calendars do
      resource :destroy_events, only: :destroy
    end
    resources :events, except: :index do
      resources :attendees, only: :destroy
    end
  end
  resources :attendees
  namespace :api do
    resources :calendars, only: [:update, :new]
    resources :users, only: :index
    resources :events, except: [:edit, :new]
    resources :request_emails, only: :new
  end
end
