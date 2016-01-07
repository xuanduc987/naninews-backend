class ApplicationController < ActionController::API
  include ActionController::Serialization
  include ActionController::HttpAuthentication::Token::ControllerMethods

  attr_reader :current_user

  before_action :set_current_user

  protected

  def authenticate
    authenticate_or_request_with_http_token do |token, _|
      @current_user || ApiToken.where(token: token).exists
    end
  end

  private

  def set_current_user
    token, = ActionController::HttpAuthentication::Token.token_and_options(request)
    api_token = ApiToken.find_by(token: token)
    @current_user ||= api_token.try(:user)
  end

  def request_http_token_authentication(realm = "Application")
    headers["WWW-Authenticate"] = %(Token realm="#{realm.delete('"')}")
    render json: { error: "HTTP Token: Access denied." }, status: :unauthorized
  end
end
