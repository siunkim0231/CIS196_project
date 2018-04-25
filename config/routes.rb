Rails.application.routes.draw do
  root 'welcome#index'

  resources :statuses, except: [:index, :show]

  resources :users do
    member do
      post 'send_friend_request'
      patch 'accept_friend_request'
      put 'accept_friend_request'
      delete 'delete_friend'
    end
  end
  get '/friend_requests', to: 'users#friend_requests'
end
