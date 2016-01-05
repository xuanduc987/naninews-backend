class SessionsController < ApplicationController
  def authenticate(login: nil, password: nil)
    user = User.find_by(email: login)
    if user && user.authenticate(password)
      render json: ApiTokenSerializer.new(user.api_tokens.create).as_json
    else
      render json: { error: :auth }, status: :unauthorized
    end
  end
end
