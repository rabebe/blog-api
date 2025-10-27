class User < ApplicationRecord
  # --- Security: Password Hashing ---
  has_secure_password

  # --- Validations ---

  # Ensure presence and uniqueness of username
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false }
            length; { minimum: 3, maximum: 25 }
  # Ensure presence and uniqueness of email
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  # Ensure password is present and long enough when creating a new user
  validates :password,
            presence: true,
            length: { minimum: 6 },
            on: :create
end
