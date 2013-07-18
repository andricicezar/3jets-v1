Airplanes::Application.routes.draw do
  root :to => "main#index", :as => "home"

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users, :controllers => {:registrations => "registrations", :omniauth_callbacks => "omniauth_callbacks"}
  ActiveAdmin.routes(self)
  devise_scope :user do
    get "users/guest" => "registrations#guest", :as => "login_like_guest"
    post "users/guest" => "registrations#create_guest_user", :as => "guest_login"
  end
  get "user/:id" => "user#profile", :as => "user_profile"

  get "friends" => "user#friends"
  get "games" => "user#games"
  get "notifications" => "user#notifications"
  get "info" => "user#angular_info"

  get "user/:id/friend" => "user#friend", :as => "be_friend_with_user"
  get "user/:id/invite" => "user#invite", :as => "invite_user"
  get "user/:id/position" => "user#position", :as => "user_position"

  get "check" => "main#index2"
  get "facebook_friends" => "main#facebook_friends"

  get "ranking/:id" => "main#ranking", :as => "ranking"

  get "notification/:id/delete" => "notification#destroy", :as => "destroy_notification"

  get "play/" => "game#init", :as => "play"
  get "match/:conf" => "game#match", :as => "match"
  get "game/search/:conf" => "game#search", :as => "search_game"

  get "game/:id" => "game#play", :as => "game"
  get "game/:id/wait" => "game#wait", :as => "game_wait"
  get "game/:id/add_user/:conf" => "game#adduser", :as => "game_adduser"
  get "game/:id/move" => "game#asdf", :as => "game_move"
  get "game/:id/exit" => "game#exit", :as => "game_exit"
  get "game/:id/victory" => "game#finish", :as=> "game_victory"
  get "game/:id/validate" => "game#validatedm", :as => "game_validate"
  get "game/:id/check" => "game#check", :as => "game_check"

  get "search_users" => "main#search_users", :as => "search_users"
  get "search_friends" => "main#search_friends", :as => "search_friends"
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
