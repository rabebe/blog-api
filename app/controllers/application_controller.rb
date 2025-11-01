class ApplicationController < ActionController::API
  include JsonWebToken

  before_action :authenticate_request

  def authorize_admin
    unless current_user&.is_admin?
      render json: { error: "Forbidden. Admin privileges required" }, status: :forbidden
    end
  end

  # Helper method to find the current user based on the JWT token
  def current_user
    @current_user
  end

  private

  # Authenticates the request by verifying the JWT token.
  def authenticate_request
    auth_header = request.headers["Authorization"]
    token = nil

    if auth_header.present? && auth_header.start_with?("Bearer ")
      token = auth_header.split(" ").last
    end

    if token.present?
      begin
        @decoded = JsonWebToken.decode(token)

        unless @decoded.present?
          return render json: { error: "Invalid token format or expired" }, status: :unauthorized
        end

        @current_user = User.find(@decoded[:user_id])

      rescue ActiveRecord::RecordNotFound
        render json: { error: "Invalid token: User not found" }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
      end
    else
      render json: { error: "Forbidden. Authentication required" }, status: :forbidden
    end
  end
end
