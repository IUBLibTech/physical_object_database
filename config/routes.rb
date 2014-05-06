Pod::Application.routes.draw do
  root "physical_objects#index"

  resources :batches do
    get :search, on: :collection
  end

  resources :bins do
    get :search, on: :collection
    post :add_barcode_item, on: :member
    post :unbatch, on: :member

    resources :boxes, only: [:new, :create]
  end

  resources :boxes, except: [:edit] do
    post :add_barcode_item, on: :member
    post :unbin, on: :member
  end

  resources :condition_status_templates

  resources :physical_objects do
    #Keep?  in javascript
    #get :get_tm_form, on: :member
    get :split_show, on: :member
    get :upload_show, on: :collection

    post :split_update, on: :member
    post :upload_update, on: :collection
    post :unbin, on: :member
    post :unbox, on: :member

    #resource digital_files
  end

  resources :picklist_specifications do
    #list_pos
    #keep?  in javascript
    #get_form
    #ot_hash: delete from controller?
    #format_where
    get :query, on: :member
    patch :query_add, on: :member
  end

  resources :picklists do
    #FIXME: refactor into physical_object?
    get :remove, on: :member
  end

  resources :search, controller: :search, only: [:index] do
    post :advanced_search, on: :collection
    post :search_results, on: :collection
  end

  resources :status_templates, only: [:index]

  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete
  resources :sessions, only: [:new, :destroy] do
    get :validate_login, on: :collection
  end

  resources :workflow_status_templates

  #old routing scheme was:
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
