Rails.application.routes.draw do
  get "/authenticate" => "sessions#authenticate"

  resources :posts, except: [:new, :edit] do
    resources :votes, only: [:create]
    resources :comments, except: [:new, :edit], shallow: true
  end
end
