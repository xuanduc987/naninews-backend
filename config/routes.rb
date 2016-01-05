Rails.application.routes.draw do
  get "/authenticate" => "sessions#authenticate"
end
