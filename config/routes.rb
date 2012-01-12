RefineryTest::Application.routes.draw do
  #devise_for :users
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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  ## REFINERY BLOG
    scope(:path => 'blog', :module => 'refinery/blog') do
      root :to => 'posts#index', :as => 'blog_root'
      match 'feed.rss', :to => 'posts#index', :as => 'blog_rss_feed', :defaults => {:format => "rss"}
      match ':id', :to => 'posts#show', :as => 'blog_post'
      match 'categories/:id', :to => 'categories#show', :as => 'blog_category'
      match ':id/comments', :to => 'posts#comment', :as => 'blog_post_blog_comments'
      get 'archive/:year(/:month)', :to => 'posts#archive', :as => 'archive_blog_posts'
      get 'tagged/:tag_id(/:tag_name)' => 'posts#tagged', :as => 'tagged_posts'
    end

    scope(:path => 'refinery', :as => 'admin', :module => 'refinery/admin') do
      scope(:path => 'blog', :as => 'blog', :module => 'blog') do
        root :to => 'posts#index'
        resources :posts do
          collection do
            get :uncategorized
            get :tags
          end
        end

        resources :categories

        resources :comments do
          collection do
            get :approved
            get :rejected
          end
          member do
            get :approved
            get :rejected
          end
        end

        resources :settings do
          collection do
            get :notification_recipients
            post :notification_recipients

            get :moderation
            get :comments
            get :teasers
          end
        end
      end
    end
    ## END REFINERY BLOG
   
    
    ## REFINERY AUTH
    devise_for :users, :controllers => {
      :sessions => 'sessions',
      :registrations => 'users',
      :passwords => 'passwords'
    }, :path_names => {
      :sign_out => 'logout',
      :sign_in => 'login',
      :sign_up => 'register'
    }

    # Override Devise's default after login redirection route.  This will pushed a logged in user to the dashboard.
    get 'refinery', :to => 'refinery/admin/dashboard#index', :as => :refinery_root
    get 'refinery', :to => 'refinery/admin/dashboard#index', :as => :user_root

    # Override Devise's other routes for convenience methods.
    #get 'refinery/login', :to => "sessions#new", :as => :new_user_session
    #get 'refinery/login', :to => "sessions#new", :as => :refinery_login
    #get 'refinery/logout', :to => "sessions#destroy", :as => :destroy_user_session
    #get 'refinery/logout', :to => "sessions#destroy", :as => :logout

    scope(:path => 'refinery', :as => 'admin', :module => 'refinery/admin') do
      resources :users, :except => :show
    end
    
    
    ## END REFINERY AUT
    ## REFINERY SETTINGS
    scope(:path => 'refinery', :as => 'admin', :module => 'refinery/admin') do
      resources :settings,
                :except => :show,
                :as => :refinery_settings,
                :controller => :refinery_settings
    end
    ## END REFINERY SETTINGS
    ## REFINERY RESOURCES
    # match '/system/resources/*dragonfly', :to => Dragonfly[:resources]
    
    scope(:path => 'refinery', :as => 'admin', :module => 'refinery/admin') do
      resources :resources, :except => :show do
        collection do
          get :insert
        end
      end
    end
    ## END REFINERY RESOURCES
    ## REFINERY PAGES
    get '/pages/:id', :to => 'refinery/pages#show', :as => :page
    
    scope(:path => 'refinery', :as => 'admin', :module => 'refinery/admin') do
      resources :pages, :except => :show do
        collection do
          post :update_positions
        end
      end
    
      resources :pages_dialogs, :only => [] do
        collection do
          get :link_to
          get :test_url
          get :test_email
        end
      end
    
      resources :page_parts, :only => [:new, :create, :destroy]
    end
    ## END REFINERY PAGES
    
    ## REFINERY IMAGES
    # match '/system/images/*dragonfly', :to => Dragonfly[:refinery_images]
    
    scope(:path => 'refinery', :as => 'admin', :module => 'refinery/admin') do
      resources :refinery_images, :except => :show do
        collection do
          get :insert
        end
      end
    end
    ## END REFINERY IMAGES
    
    ## REFINERY CORE
    # filter(:refinery_locales) if defined?(RoutingFilter::RefineryLocales) # optionally use i18n.
    

    
    match 'wymiframe(/:id)', :to => 'refinery/fast#wymiframe', :as => :wymiframe
    
    scope(:path => 'refinery', :as => 'admin', :module => 'refinery/admin') do
      root :to => 'dashboard#index'
      resources :dialogs, :only => :show
    end
    
    match '/refinery/update_menu_positions', :to => 'refinery/admin/refinery_core#update_plugin_positions'
    
    match '/sitemap.xml' => 'refinery/sitemap#index', :defaults => { :format => 'xml' }
    
     match '/refinery/*path' => 'refinery/admin/base#error_404'
    ## END REFINERY CORE
    
    ## REFINERY DASHBOARD
    scope(:path => 'refinery', :as => 'admin', :module => 'refinery/admin') do
      match 'dashboard',
            :to => 'dashboard#index',
            :as => :dashboard
    
      match 'disable_upgrade_message',
            :to => 'dashboard#disable_upgrade_message',
            :as => :disable_upgrade_message
    end
    ## END REFINERY DASHBOARD
    

    
       match '*path' => 'refinery/pages#show'

      
  # Marketable URLs should be appended to routes by the Pages Engine.
  # Catch all routes should be appended to routes by the Core Engine.

  root :to => 'refinery/pages#home'
end
