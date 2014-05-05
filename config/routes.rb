#FIXME: fix "delete" calls
#FIXME: test all functions
Pod::Application.routes.draw do
  root "physical_objects#index"

  resources :batches do
    get :search, on: :collection
  end
  	#bins
  resources :bins do
    get :search, on: :collection
    get :bin_add_item, on: :member

    get :remove_physical_object, on: :member

    get :show_box, on: :member
    get :edit_box, on: :member
    get :remove_box, on: :member
    get :box_add_item, on: :member
    post :box_add_item, on: :member
  end
  	#box
	#physical_object
	#other commands
  resources :boxes
  	#needs native commands
  resources :condition_status_templates
  resources :condition_statuses
  	#command condition
  #resources :condition_statuses
  #resources :digital_files
  resources :physical_objects do
    get :upload_show, on: :member
    get :split_show, on: :member
  end
  	#various commands
  resources :picklist_specifications do
    get :query, on: :member
  end
  	#various commands
  resources :picklists
  	#remove
	#csv
  resources :search, controller: :search do
    match :advanced_search, on: :collection, via: [:get, :post]
  end
  #match 'search', to: 'search#index', via: [:get, :post]
#status templates controller
  resources :status_templates
#test controller -- empty?
#workflow status controller -- empty?
  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete
  resources :sessions, only:  [:new, :destroy] do
    get :validate_login, on: :collection
    #get :signin, to: :new, on: :collection
    #delete :signout, to: :destroy, on: :collection
  end
  resources :workflow_status_templates
  resources :workflow_statuses

  #technical metadata
  
  #match ':controller(/:action(/:id))', :via => [:get, :post, :patch]

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
