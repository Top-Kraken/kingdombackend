Rails.application.routes.draw do
  get 'users/prospect'
  get 'users/contacted'
  # users
  resources :users, only: [:update]
  # demos
  resources :demos do
    post :send_reminder
  end
  get '/settings', to: 'demos#settings', as: 'demo_settings'
  # availabilities
  resources :availabilities
  # leads
  resources :leads do
    member do
      patch :change_stage
      post :closed_stage
    end

    collection do
      get :new_csv
      get :new_leads
    end
  end
  get '/lead_view', to: 'leads#lead_view', as: 'lead_view'
  get '/pipeline_view', to: 'leads#pipeline_view', as: 'pipeline_view'
  # users
  devise_for :users, controllers: { registrations: 'registrations', passwords: 'passwords' }

  get '/confirm_phone', to: 'static#confirm_phone', as: :confirm_phone
  post '/verify_otp', to: 'static#verify_otp', as: :verify_otp
  get '/after_sign_up', to: 'static#after_sign_up', as: :after_sign_up
  get "/generate_report", to: 'static#generate_report'
  post '/add_lead', to: 'static#add_lead', as: :web_add_lead
  get '/add_domain', to: "subscriptions#add_domain"
  post '/select_domain', to: "subscriptions#select_domain"
  post '/search_domain', to: "subscriptions#search_domain"

  get 'users/:id/prospect/:lead_number', to: 'users#prospect', as: :lead_prospect
  get 'users/:id/contacted/:lead_number', to: 'users#contacted', as: :lead_contacted
  get 'users/:id/demo/:lead_number', to: 'users#demo', as: :lead_demo
  get 'users/:id/followup/:lead_number', to: 'users#followup', as: :lead_followup
  get 'users/:id/closed/:lead_number', to: 'users#closed', as: :lead_closed
  post '/book_demo', to:'users#book_demo'
  get '/book_new', to:'users#book_new'

  get '/pay', to: 'static#pay'

  # registrations
  devise_scope :user do
    get 'registrations/new_subscription'
    get 'registrations/add_domain'
    get 'registrations/add_leads'
    post 'registrations/select_domain'
    post 'registrations/search_domain'
  end

  # CSV import route
  post 'leads/import', to: 'leads#import'

  resources :appointments do
   collection { get :day_view }
 end

  resources :subscriptions
  get 'users/:id', to: "static#user_template"
  
  # home page
  root 'static#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
