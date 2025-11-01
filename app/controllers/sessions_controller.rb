class SessionsController < ApplicationController
  # This action authenticates a user and returns a JWT token upon successful login.
  skip_before_action :authenticate_request, only: [ :create ]

  def create
    user = User.find_by(email: params[:email])

    # Authenticate the user
    if user && user.authenticate(params[:password])
      # Successful authentication
      token = JsonWebToken.encode(user_id: user.id)

      render json: { token: token, username: user.username }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    head :no_content
  end
end
