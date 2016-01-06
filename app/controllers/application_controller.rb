class ApplicationController < ActionController::API
  include ActionController::Serialization
  include ActionController::HttpAuthentication::Token::ControllerMethods

  protected

  def authenticate
    authenticate_or_request_with_http_token do |token, _|
      token = ApiToken.find_by(token: token)
      @user = token.try(:user)
      token.present?
    end
  end

  def request_http_token_authentication(realm = "Application")
    headers["WWW-Authenticate"] = %(Token realm="#{realm.delete('"')}")
    render json: { error: "HTTP Token: Access denied." }, status: :unauthorized
  end
end
