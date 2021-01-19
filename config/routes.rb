Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: redirect('/zipper/new')

  resources :files, path: 'zipper', only: [:new, :show, :create], constraints: { id: /\d{13}/ } do
    member do
      get '/download', action: :download
    end
  end
end
