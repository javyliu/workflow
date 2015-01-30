require 'sidekiq/web'
Rails.application.routes.draw do

  root 'welcome#index'

  resources :sessions,only: [:new,:create,:destroy]

  resources :oa_configs,only: [:update,:index]

  resources :attend_rules,only: [:index,:update,:edit]

  resources :report_titles,only:[:index,:update]

  resources :checkinouts,only: [:index] do
    collection do
      get ":only" => "checkinouts#index",as: :my
    end

  end

  resources :year_infos

  resources :journals do
   collection do
     put ":user_id/:date" => :update,as: :user
   end
  end

  resources :episodes

  resources :holidays

  resources :users do
    collection do
      get :checkinout
      post "confirm/:task" => :confirm, as: :confirm
      get "kaoqing/:task" => :kaoqing,as: :kaoqing
      get :home
    end
  end

  resources :departments,except: [:destroy,:new,:create]

  resources :spec_days

  mount Sidekiq::Web => '/sidekiq'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
