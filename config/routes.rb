Rails.application.routes.draw do
  get "/authenticate" => "sessions#authenticate"

  resources :posts, except: [:new, :edit]
end
