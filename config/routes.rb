Rails.application.routes.draw do
  root 'home#index'
  
  namespace :api do
    namespace :v1 do
      post 'login', to: 'authentication#create'

      resources :users, only: %i[show create] do
        member do
          get :confirm_email
        end
      end
    end
  end
end
