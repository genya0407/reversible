Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'rooms#index'

  resources :rooms, only: %i[index create show] do
    member do
      get :watcher
      get :first_attacker
      get :second_attacker
    end
    
    resources :players, only: %i[show] do
      member do
        post :authorize
      end

      resources :moves, only: %i[create]
    end
  end
end
