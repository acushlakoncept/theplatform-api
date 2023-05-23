Rails.application.routes.draw do
  root 'home#index'
  
  namespace :api do
    namespace :v1 do
      post 'login', to: 'authentication#create'

      resources :users, only: %i[show create] do
        collection do
          get 'confirm-email/:confirm_token', action: :confirm_email
        end
      end   
    end
  end
end
