Rails.application.routes.draw do
  get 'home/index'
  root to: 'home#index'
  get '/tweets', to: 'twitter#tweets'
  get '/word-cloud', to: 'twitter#word_cloud'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
