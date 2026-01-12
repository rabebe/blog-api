class SessionsController < ApplicationController
  skip_before_action :authenticate_request, only: [ :create ]

  # POST /login
  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      # Check email verification for regular users
      if !user.is_verified && !user.admin?
        render json: { error: "Please verify your email first" }, status: :forbidden
        return
      end

      # Generate token and return user info
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        token: token,
        user: {
          username: user.username,
          email: user.email,
          is_admin: user.admin?
        }
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end


  def destroy
    render json: { message: "Logged out successfully" }, status: :ok  end
end
