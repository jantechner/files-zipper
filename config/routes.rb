Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: redirect('/zipper/new')

  get '/zipper/new', to: 'files#new'
  post '/zipper', to: 'files#create'
  get 'zipper/:id', to: 'files#show'
  get 'zipper/:id/download', to: 'files#download'
end
