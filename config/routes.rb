PlayerSublimevideo::Application.routes.draw do
  ActiveAdmin.routes(self)

  # TODO: Move this to active admin
  resources :packages, only: [:create]

  # namespace :private_api do
  #   resources :packages, only: [:index, :show]
  # end

  # root to: 'packages#index'
end
