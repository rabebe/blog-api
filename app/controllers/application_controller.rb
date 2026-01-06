class ApplicationController < ActionController::API
  # Protect all routes by default
  before_action :authenticate_request

  # Helper method to find the current user
  def current_user
    @current_user
  end

  # Helper for admin-only routes
  def authorize_admin
    # Use .admin? or .is_admin? based on your User model column
    unless current_user&.admin?
      render json: { error: "Forbidden. Admin privileges required" }, status: :forbidden and return
    end
  end
  
  private

  def authenticate_request
    # 1. Extract token from Authorization header
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    # 2. Halt if token is missing
    if token.blank?
      render json: { error: "Authentication required" }, status: :unauthorized and return
    end

    begin
      # 3. Decode token
      @decoded = JsonWebToken.decode(token)
      
      # 4. Find user
      @current_user = User.find(@decoded[:user_id])

    rescue JWT::ExpiredSignature
      # Specific rescue for expired tokens (triggers the frontend redirect)
      render json: { error: "Token has expired. Please log in again." }, status: :unauthorized and return
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :unauthorized and return
    rescue JWT::DecodeError => e
      # Catches malformed tokens or signature mismatches
      render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized and return
    rescue => e
      # Fallback to prevent 500 errors if anything else goes wrong during auth
      Rails.logger.error "Auth Error: #{e.message}"
      render json: { error: "Authentication failed" }, status: :unauthorized and return
    end
  end
end