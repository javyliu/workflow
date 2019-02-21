require 'sidekiq/web'
Rails.application.routes.draw do

  resources :em_services do
    get :list, on: :collection
  end

  resources :em_ser_cates

  get "assaults/:task" => "assaults#show",as: :assault,task: /\d+|(.+?:)+\d+/
  resources :assaults, except: [:show]

  resources :roles

  resources :approves,only: [:create,:update]

  root 'welcome#index'

  resources :sessions,only: [:index,:new,:create,:destroy]

  resources :oa_configs,only: [:update,:index]

  resources :attend_rules,only: [:index,:update,:edit]

  resources :report_titles,only:[:index,:update]

  resources :checkinouts,only: [:index,:new,:create] do
    collection do
      get :list
    end

  end

  resources :year_infos,except: [:show,:destroy]

  resources :journals do
   collection do
     get :list
     put ":user_id/:date" => :update,as: :user
   end
  end

  get "episodes/list" => "episodes#list",as: "list_episodes"
  #get "episodes/new/:holiday_id" => "episodes#new",as: :new_episode
  #get "episodes/:id/edit" => "episodes#edit",as: :edit_episode
  get "episodes/:task" => "episodes#show",as: :episode,task: /\d+|(.+?:)+\d+/
  resources :episodes,except: [:show]

  resources :holidays

  resources :users do
    collection do
      get :checkinout
      get :change_pwd
      post "confirm/:task" => :confirm, as: :confirm
      get "kaoqin/:task(/:cmd)" => :kaoqing,as: :kaoqing
      get :home
      get :manual_unify_delete
      delete :unify_delete
    end
    member do
      put :unify_delete
      put :unify_reset
    end
  end

  resources :departments,except: [:new,:create]

  resources :spec_days

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      username == 'admin' && password == 'Javy123123'
  end# if Rails.env.production?
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
