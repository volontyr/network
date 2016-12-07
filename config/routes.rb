Rails.application.routes.draw do

  root 'network#new'
  get 'network/new'
  post '/create'                   => 'network#create'
  get 'network'                    => 'network#index'
  post 'network/update'            => 'network#network_update'
  post 'network/add_node'          => 'network#add_node'
  post 'network/remove_node'       => 'network#remove_node'
  post 'network/add_channel'       => 'network#add_channel'
  post 'network/remove_channel'    => 'network#remove_channel'
  post 'network/update_channel'    => 'network#update_channel'
  post 'network/send_message'      => 'network#send_message'
  post 'network/generate_messages' => 'network#generate_messages'
  post 'network/save_network'      => 'network#save_network'
  post 'network/load_network'      => 'network#load_network'
  post 'network/update_node'       => 'network#update_node'
  post 'network/find_routes_by'    => 'network#find_routes_by'
  get 'network/messages_statistics' => 'network#statistics'

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
