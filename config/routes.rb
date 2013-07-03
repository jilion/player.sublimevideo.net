PlayerSublimevideo::Application.routes.draw do
  resources :packages, only: [:index, :show, :create]

  root to: redirect('/packages')
end
