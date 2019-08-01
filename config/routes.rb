Rails.application.routes.draw do
  get     'password_resets/new'
  get     'password_resets/edit'
  root    'static_pages#home'
  get     '/help'                           ,to: 'static_pages#help'
  get     '/about'                          ,to: 'static_pages#about'
  get     '/contact'                        ,to: 'static_pages#contact'
  get     '/signup'                         ,to: 'users#new'
  post    '/signup'                         ,to: 'users#create'
  get     '/login'                          ,to: 'sessions#new'
  post    '/login'                          ,to: 'sessions#create'
  delete  '/logout'                         ,to: 'sessions#destroy'
  get     '/resources'                      ,to: 'resources#index'
  get     '/resources/new'                  ,to: 'resources#new'
  post    '/resources/new'                  ,to: 'resources#create'
  # Need this for CRUD operations on a given user - see the CRUD table for the provided actions
  resources :users do
    # Makes it possible to have URLs such as /users/:id/following and /users/:id/followers
    # (arranges for the routes to respond to URLs containing the user id)
    member do
      # 'get' because we're showing data, so we use the GET method
      get :following, :followers
    end
  end
  resources :resources,           only: [:edit, :show, :destroy]
  resources :account_activation,  only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
end
