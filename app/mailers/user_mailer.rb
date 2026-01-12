class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @verification_url = "#{Rails.application.config.action_mailer.default_url_options[:host]}:#{Rails.application.config.action_mailer.default_url_options[:port]}/verify-email?token=#{user.verification_token}"

    mail(
      to: @user.email,
      subject: "Verify your email address"
    )
  end
end
