Rails.application.routes.draw do
  # Court realtime activities
  resources :courts do
    member do
      get :realtime
    end
    resources :court_activities, only: [ :create ] do
      collection do
        post :check_in
        post :check_out
        post :report
      end
    end
  end
  # Mount ActionCable
  mount ActionCable.server => "/cable"

  # Authentication routes
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#destroy"
  delete "/logout", to: "sessions#destroy"
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  root "home#index"

  # 3-Second Rule Routes: Quick Actions
  get "quick_match", to: "games#quick_match"  # 1st click: Quick match
  get "join_game/:id", to: "games#quick_join", as: :quick_join  # 2nd click: Join specific game
  post "confirm_join/:id", to: "games#confirm_join", as: :confirm_join  # 3rd click: Confirm

  # Game Management Routes
  resources :games do
    member do
      post :join
      delete :leave
      post :apply
      delete :cancel_application
      post "approve_application/:application_id", to: "games#approve_application", as: :approve_application
      post "reject_application/:application_id", to: "games#reject_application", as: :reject_application
      post "confirm_payment/:application_id", to: "games#confirm_payment", as: :confirm_payment
      post :duplicate  # 경기 복사 기능
    end
    collection do
      get :nearby
      get :today
    end

    # 중첩된 라우트
    resources :game_applications, only: [] do
      resources :payments, only: [ :new, :create, :show ]
    end

    # 결제 환불 라우트
    resources :payments, only: [] do
      resources :refunds, only: [ :new, :create ]
    end

    # 평가 라우트
    resources :player_evaluations, only: [ :index, :new, :create ]
    resources :ratings, only: [ :index, :new, :create ]
  end

  # 토스페이먼츠 결제 결과 처리
  scope :payments do
    get :success, to: "payments#success"
    get :fail, to: "payments#fail"
  end

  resources :courts, only: [ :index, :show ] do
    resources :games, only: [ :index, :new, :create ]
  end

  # Community Routes
  scope :community, as: :community do
    get "/", to: "community#index"
    get :free_board, to: "community#free_board"
    get :marketplace, to: "community#marketplace"
    get :teams, to: "community#teams"
    get :courts_info, to: "community#courts_info"
    get :new_post, to: "community#new_post"
  end

  # Posts and Comments
  resources :posts do
    resources :comments, except: [ :show, :index ]
  end

  # Outdoor Courts
  resources :outdoor_courts, path: "outdoor-courts" do
    collection do
      get :nearby
    end
  end

  # Team Management Routes
  resources :teams do
    member do
      get :search_users
      post :add_member
      delete :remove_member
    end
  end
  
  # Tournament Routes
  resources :tournaments do
    member do
      get :register
      post :create_team
      get :share
      get :preview
      post :publish
      get :bracket
      get :check_in
    end
    collection do
      get :past
      get :notifications
    end
    resources :matches, controller: "tournament_matches", only: [ :show ]
    
    # Tournament registration with team management
    resources :registrations, controller: 'tournament_registrations', only: [:new, :create] do
      collection do
        get :load_team_members
        get :search_players
      end
    end
    
    # Tournament management features
    resource :dashboard, controller: 'tournament_dashboards' do
      member do
        post :announce
        post :pause
        post :resume
        post :update_progress
        post :batch_approve_teams
        post :batch_send_reminders
        get :generate_report
      end
    end
    
    resources :checklists, controller: 'tournament_checklists' do
      member do
        post :complete
        post :uncomplete
      end
      collection do
        post :execute_automated
      end
    end
    
    resources :check_ins, controller: 'tournament_check_ins' do
      member do
        post :check_in
        post :check_out
      end
      collection do
        post :scan
        post :generate_all_qr
        get :download_qr_codes
      end
    end
    
    resources :standings, only: [:index]

    # 대회 간편 생성
    resources :quick, controller: "tournament_quick" do
      collection do
        get :templates
        post :create
        get :show
        patch :update
        patch :previous
      end
      member do
        get :preview
        post :publish
        get :share
      end
    end

    # 대회 실시간 운영
    resource :live, controller: "tournament_live" do
      get :dashboard
      get :score_board
      post :update_score
      post :update_match
      post :check_in
      get :feed
      post :announcement
    end

    # 대회 포스터
    resources :posters, controller: "tournament_posters" do
      member do
        get :download
      end
    end

    # 대회 예산 관리
    resources :budgets, controller: "tournament_budgets" do
      collection do
        get :report
        post :settlement
      end
    end
  end

  # Profile Routes
  scope :profile, as: :profile do
    get "/", to: "profiles#show"
    get :edit, to: "profiles#edit"
    patch :update, to: "profiles#update"
    get :stats, to: "profiles#stats"
    get :history, to: "profiles#history"
  end


  # User Management (legacy support)
  resources :users, only: [ :show, :edit, :update ] do
    member do
      get :history
      get :stats
      get :notification_settings
      patch :update_notification_settings
      get :achievements
      get :points
    end
  end

  # Achievements and Points
  resources :achievements, only: [ :index, :show ]
  resources :points, only: [ :index ]

  # Premium Stats Routes
  resources :stats, only: [ :index, :show ] do
    collection do
      get :game_log
      get "season/:season_name", to: "stats#season", as: :season
      get "compare/:user_id", to: "stats#compare", as: :compare
    end
  end

  # Premium membership
  get "/premium", to: "premium#index"
  get "/premium/subscribe", to: "premium#subscribe"
  post "/premium/subscribe", to: "premium#subscribe"
  get "/premium/success", to: "premium#payment_success"
  get "/premium/billing/success", to: "premium#billing_success"
  get "/premium/fail", to: "premium#payment_fail"
  get "/premium/manage", to: "premium#manage"
  post "/premium/cancel", to: "premium#cancel"

  # Notifications
  resources :notifications, only: [ :index, :show, :destroy ] do
    member do
      patch :mark_as_read
      patch :mark_as_unread
    end
    collection do
      get :unread_count
      patch :mark_all_as_read
      delete :destroy_all_read
    end
  end

  # Quick Match Features
  resources :quick_matches, only: [ :new, :create ] do
    collection do
      get :preferences
      patch :update_preferences
      post :toggle_auto_match
    end
  end

  resources :match_pools, only: [ :index, :show ] do
    member do
      post :join
      delete :leave
    end
  end

  # Suggestions
  resources :suggestions, only: [ :create ]

  # Admin Routes
  scope :admin, as: :admin do
    get "/", to: "admin#dashboard"
    get :dashboard, to: "admin#dashboard"
    get :users, to: "admin#users"
    get :games, to: "admin#games"
    get :payments, to: "admin#payments"
    get :applications, to: "admin#applications"
    get :analytics, to: "admin#analytics"
    get :reports, to: "admin#reports"
    get :settings, to: "admin#settings"
    get :logs, to: "admin#logs"
    get :suggestions, to: "admin#suggestions"
    get :resolved_suggestions, to: "admin#resolved_suggestions"
    get :tournaments, to: "admin#tournaments"
    get :export_data, to: "admin#export_data"
    post "user_action/:id", to: "admin#user_action", as: :user_action
    post "game_action/:id", to: "admin#game_action", as: :game_action
    post "payment_action/:id", to: "admin#payment_action", as: :payment_action
    post "application_action/:id", to: "admin#application_action", as: :application_action
    post "suggestion_action/:id", to: "admin#suggestion_action", as: :suggestion_action
    post "tournament_action/:id", to: "admin#tournament_action", as: :tournament_action
    patch "settings/:id", to: "admin#update_setting", as: :update_setting
  end
  
  # Tournament Templates
  resources :tournament_templates do
    member do
      post :use
      post :duplicate
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
