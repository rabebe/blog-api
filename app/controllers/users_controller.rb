class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [ :create, :verify_email, :resend_verification ]

  # POST /signup
  def create
    user = User.new(user_params)

    if user.save
      user.update!(
        verification_token: SecureRandom.uuid
      )

      UserMailer.verification_email(user).deliver_later

      render json: {
        message: "Account created. Please check your email to verify your account.",
        username: user.username,
        email: user.email
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /verify-email?token=XXXX
  def verify_email
    user = User.find_by(verification_token: params[:token])
    if user
      user.is_verified = true   # <-- use the correct column
      user.verification_token = nil
      user.save!
      render json: { message: "Email verified successfully." }
    else
      render json: { error: "Invalid token." }, status: :not_found
    end
  end


  # POST /resend-verification
  def resend_verification
    user = User.find_by(email: params[:email])

    if user
      if user.is_verified
        render json: { message: "Email is already verified." }, status: :ok
      else
        user.generate_verification_token!  # We'll add this in the model
        UserMailer.verification_email(user).deliver_now
        render json: { message: "Verification email resent." }, status: :ok
      end
    else
      render json: { error: "User not found." }, status: :not_found
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end
end
