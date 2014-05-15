Pod::Application.routes.draw do
  #get "physical_objects/new"
  #get "physical_objects/create"
  #get "physical_objects/index"
  #get "physical_objects/show"
  #get "physical_objects/edit"
  #get "physical_objects/update"
  #get "physical_objects/delete"
  #get "physical_objects/destroy"
 
  root "physical_objects#index"
  match '/batches/search',	to: 'batches#search',	via: [:get, :post]
  resources :batches
  resources :bins
  resources :boxes
  resources :physical_objects do
    get :get_tm_form, on: :collection
    get :download_spreadsheet_example, on: :collection
  end
  resources :picklists

  resources :sessions, only:  [:new, :destroy]

  match '/signin',      to: 'sessions#new',             via: 'get'
  match '/signout',     to: 'sessions#destroy',         via: 'delete'
  
  match ':controller(/:action(/:id))', :via => [:get, :post, :patch]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
