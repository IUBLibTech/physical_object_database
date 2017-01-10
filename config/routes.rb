Pod::Application.routes.draw do

  get 'welcome/', to: 'welcome#index', as: 'welcome_index'
  root 'welcome#index'

  resources :batches do
    patch :add_bin, on: :member
    post :remove_bin, on: :member
    get :workflow_history, on: :member
    get :list_bins, on: :member
    patch :archived_to_picklist, on: :member
  end

  resources :bins do
    post :add_barcode_item, on: :member
    post :unbatch, on: :member
    patch :seal, on: :member
    patch :unseal, on: :member
    get :show_boxes, on: :member
    get :workflow_history, on: :member
    patch :assign_boxes, on: :member
    resources :boxes, only: [:index, :new, :create]
  end

  resources :boxes  do
    post :add_barcode_item, on: :member
    post :unbin, on: :member
  end

  get 'collection_owner/', to: 'collection_owner#index', as: 'collection_owner_index'
  get 'collection_owner/search', to: 'collection_owner#search', as: 'collection_owner_search'
  get 'collection_owner/upload_spreadsheet', to: 'collection_owner#upload_spreadsheet', as: 'collection_owner_upload_spreadsheet'
  post 'collection_owner/search_results', to: 'collection_owner#search_results', as: 'collection_owner_search_results'
  get 'collection_owner/:id', to: 'collection_owner#show', as: 'collection_owner_show'

  resources :condition_status_templates

  resources :group_keys do
    patch :reorder, on: :member
    patch :include, on: :member

    resources :physical_objects, only: [:new]
  end

  resources :machines

  resources :messages

  resources :physical_objects do
    get :download_spreadsheet_example, on: :collection
    get :tm_form, on: :collection
    get :split_show, on: :member
    get :workflow_history, on: :member
    get :upload_show, on: :collection
    get :has_ephemera, on: :collection
    get :is_archived, on: :collection
    get :create_multiple, on: :collection
    get :edit_ephemera, on: :member
    get :contained, on: :collection
    get :generate_filename, on: :member

    patch :split_update, on: :member
    post :upload_update, on: :collection
    post :unbin, on: :member
    post :unbox, on: :member
    post :ungroup, on: :member
    post :unpick, on: :member
    patch :update_ephemera, on: :member

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

  resources :picklists, except: [:index] do
    # kludge to allow easy form submission: pack_list on collection redirects to member action
    patch :pack_list, on: :collection
    get :pack_list, on: :collection
    patch :pack_list, on: :member
    get :pack_list, on: :member
    patch :resend, on: :member

    # these 5 routes were deprecated in sprint-22 and replaced with the pack_list route - these action are no more
    # patch :assign_to_container, on: :collection
    # patch :remove_from_container, on: :collection
    # post :container_full, on: :collection
    # patch :process_list, on: :collection
    # get :process_list, on: :collection

  end

  resources :processing_steps, only: [:destroy]

  get 'responses/objects/:mdpi_barcode/metadata', to: 'responses#metadata', as: 'metadata_response'
  get 'responses/objects/:mdpi_barcode/metadata/full', to: 'responses#full_metadata', as: 'full_metadata_response'
  get 'responses/objects/:mdpi_barcode/metadata/digital_provenance', to: 'responses#digiprov_metadata', as: 'digiprov_metadata_response'
  get 'responses/objects/:mdpi_barcode/grouping', to: 'responses#grouping', as: 'grouping_response'
  post 'responses/notify', to: 'responses#notify', as: 'notify_response'
  post 'responses/objects/:mdpi_barcode/state', to: 'responses#push_status', as: 'push_status_response'
  get 'responses/objects/:mdpi_barcode/state', to: 'responses#pull_state', as: 'pull_state_response'
  get 'responses/objects/:mdpi_barcode/flags', to: 'responses#flags', as: 'flags_response'
  post 'responses/transfers', to: 'responses#transfer_request', as: 'transfer_request_response'
  get 'responses/transfers', to: 'responses#transfers_index', as: 'transfers_index_response'
  post 'responses/transfers/:mdpi_barcode', to: 'responses#transfer_result', as: 'transfer_result_response'
  get 'responses/objects/:mdpi_barcode/clear_statuses', to: 'responses#clear', as: 'clear_statuses'
  get 'responses/objects/clear_all_statuses', to: 'responses#clear_all', as: 'clear_all_statuses'
  post 'responses/objects/memnon_qc/:mdpi_barcode', to: 'responses#push_memnon_qc', as: 'push_memnon_qc'
  get 'responses/objects/memnon_qc/:mdpi_barcode', to: 'responses#pull_memnon_qc', as: 'pull_memnon_qc'
  get 'responses/objects/states', to: 'responses#pull_states', as: 'pull_states'
  get 'responses/packager/all_units/', to: 'responses#all_units', as: 'all_units'
  get 'responses/packager/units/:abbreviation', to: 'responses#unit_full_name', as: 'unit_full_name'
  post 'responses/objects/avalon_url/:group_key_id', to: 'responses#avalon_url', as: 'push_avalon_url'
  get 'responses/objects/avalon_url/:group_key_id', to: 'responses#avalon_url', as: 'pull_avalon_url'
  get 'responses/objects/digitizing_entity/:mdpi_barcode', to: 'responses#digitizing_entity', as: 'pull_digitizing_entity'
  get 'responses/processing_classes', to: 'responses#processing_classes', as: 'responses_processing_classes'

  get 'quality_control/statuses/:status', to: 'quality_control#index', as: 'quality_control_status'
  get 'quality_control/', to: 'quality_control#index', as: 'quality_control_index'
  patch 'quality_control/decide/:id', to: 'quality_control#decide', as: 'quality_control_decide'

  get 'quality_control/staging', to: 'quality_control#staging_index', as: 'quality_control_memnon_staging_index'
  post 'quality_control/staging', to: 'quality_control#staging_index', as: 'quality_control_memnon_staging_post'

  get 'quality_control/iu_staging', to: 'quality_control#iu_staging_index', as: 'quality_control_iu_staging_index_path'
  post 'quality_control/iu_staging', to: 'quality_control#iu_staging_index', as: 'quality_control_iu_staging_post_path'

  post 'quality_control/staging_post', to: 'quality_control#staging_post', as: 'quality_control_staging_post'

  post 'quality_control/stage/:id', to: 'quality_control#stage', as: 'quality_control_ajax_stage'
  get 'quality_control/stage/:id', to: 'quality_control#stage', as: 'quality_control_ajax_stage_get'
  get 'quality_control/auto_accept', to: 'quality_control#auto_accept', as: 'quality_control_auto_accept'
  get 'quality_control/direct_qc', to: 'quality_control#direct_qc', as: 'quality_control_direct_qc'
  post 'quality_control/direct_qc', to: 'quality_control#direct_qc', as: 'quality_control_direct_qc_post'

  get 'invoice/index', to: 'invoice#index', as: 'invoice_controller'
  post 'invoice/index', to: 'invoice#submit', as: 'invoice_controller_submit'
  get 'invoice/failed_message/:id', to: 'invoice#failed_message', as: 'invoice_failed_message_ajax'

  get 'xml_tester', to: 'xml_tester#index', as: 'xml_tester_index'
  post 'xml_tester_submit', to: 'xml_tester#submit', as: 'xml_tester_submit'

  resources :staging_percentages, only: [:index, :update]

  resources :returns, only: [:index] do
    get :return_bins, on: :member
    get :return_bin, on: :member
    patch :physical_object_returned, on: :member
    patch :batch_complete, on: :member
    patch :bin_unpacked, on: :member
    patch :unload_bin, on: :member
    get :return_objects, on: :collection
    post :return_object, on: :collection
  end

  resources :search, controller: :search, only: [:index] do
    post :advanced_search, on: :collection
    post :search_results, on: :collection
  end

  resources :shipments do
    get :unload, on: :member
    patch :unload_object, on: :member
    get :reload, on: :member
    patch :reload_object, on: :member
    get :shipments_list, on: :collection
    get :new_shipment, on: :collection
  end

  resources :signal_chains do
    patch :include, on: :member
    patch :reorder, on: :member
  end
  get 'signal_chains/ajax_show/:id', to: 'signal_chains#ajax_show', as: 'signal_chain_ajax_show'

  resources :digital_provenance, only: [:show, :edit, :update]

  resources :spreadsheets, except: [:new, :create]

  resources :status_templates, only: [:index]

  resources :reports, only: [:index]

  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete
  resources :sessions, only: [:new, :destroy] do
    get :validate_login, on: :collection
  end

  resources :units

  resources :users

  resources :workflow_status_templates, except: [:index]

  #old routing scheme was:
  #match ':controller(/:action(/:id))', :via => [:get, :post, :patch]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with 'rake routes'.

  # You can have the root of your site routed with 'root'
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
