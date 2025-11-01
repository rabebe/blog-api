require "jwt"
require "active_support/core_ext/numeric/time"

module JsonWebToken
  SECRET_KEY = Rails.application.credentials.secret_key_base.to_s

  # Encode a payload into a JWT
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i # Add expiration time to payload
    JWT.encode(payload, SECRET_KEY)
  end

  # Decode the token and raise an error if invalid or expired
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]

    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature, JWT::ExpiredSignature
    nil
  end
end
