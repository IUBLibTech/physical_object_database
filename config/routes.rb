Pod::Application.routes.draw do

  root "physical_objects#index"

  resources :batches do
    patch :add_bin, on: :member
    post :remove_bin, on: :member
  end

  resources :bins do
    post :add_barcode_item, on: :member
    post :unbatch, on: :member
  end

  resources :boxes, except: [:edit] do
    post :add_barcode_item, on: :member
    post :unbin, on: :member
  end

  resources :condition_status_templates

  resources :group_keys, except: [:create, :edit, :new, :update] do
    resources :physical_objects, only: [:new]
  end

  resources :physical_objects do
    get :download_spreadsheet_example, on: :collection
    get :tm_form, on: :collection
    get :split_show, on: :member
    get :upload_show, on: :collection

    patch :split_update, on: :member
    post :upload_update, on: :collection
    post :unbin, on: :member
    post :unbox, on: :member
    post :unpick, on: :member

    #resources :digital_files
  end

  resources :picklist_specifications do
    get :tm_form, on: :collection
    get :query, on: :member
    get :picklist_list, on: :collection
    get :new_picklist, on: :collection
    patch :query_add, on: :member

    # FIXME: this shouldn't be necessary but updating picklist specifications doesn't work without it
    post :update, on: :member
  end

  resources :picklists do
    patch :process_list, on: :member
    get :process_list, on: :member
    patch :assign_to_container, on: :member
    patch :remove_from_container, on: :member
    post :container_full, on: :member
  end

  resources :returns do
    get :return_bins, on: :member
    get :return_bin, on: :member
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
