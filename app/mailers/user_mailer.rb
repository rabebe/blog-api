class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user

    frontend_url = ENV.fetch("FRONTEND_URL")

    @verification_url =
      "#{frontend_url}/verify-email?token=#{user.verification_token}"

    mail(
      to: @user.email,
      subject: "Verify your email address"
    )
  end
end
