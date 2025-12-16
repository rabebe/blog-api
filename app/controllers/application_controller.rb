class ApplicationController < ActionController::API
  before_action :authenticate_request

  def authorize_admin
    unless current_user&.admin?
      render json: { error: "Forbidden. Admin privileges required" }, status: :forbidden
    end
  end

  # Helper method to find the current user based on the JWT token
  def current_user
    @current_user
  end

  private

  # Authenticate the request using JWT token
  def authenticate_request
    # Extract token from Authorization header
    token = request.headers["Authorization"]&.split(" ")&.last
    Rails.logger.warn "SECRET KEY BASE: #{Rails.application.secret_key_base}"
    Rails.logger.debug "TOKEN RECEIVED: #{token.inspect}"

    return render json: { error: "Forbidden. Authentication required" }, status: :forbidden unless token

    begin
      @decoded = JsonWebToken.decode(token) # returns HashWithIndifferentAccess
      Rails.logger.debug "DECODED TOKEN: #{@decoded.inspect}"

      unless @decoded.present?
        return render json: { error: "Invalid token format or expired" }, status: :unauthorized
      end

      @current_user = User.find(@decoded[:user_id])

    rescue ActiveRecord::RecordNotFound
      render json: { error: "Invalid token: User not found" }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
    end
  end
end
