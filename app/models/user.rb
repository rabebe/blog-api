class User < ApplicationRecord
  # --- Associations ---
  # 'dependent: :destroy' ensure that when a User is deleted
  # all associated posts are also deleted
  has_many :posts, dependent: :destroy

  # --- Security: Password Hashing ---
  has_secure_password

  # --- Validations ---

  # Ensure presence and uniqueness of username
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 25 }
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

  # --- Authorization logic ---
  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL", "fallback@example.com").downcase

  def is_admin?
    self.email.casecmp?(ADMIN_EMAIL)
  end

  # This method is required by test/fixtures/users.yml to pre-hash passwords.
  def self.digest(string)
    # Use minimum cost in tests for speed, while maintaining proper hashing logic.
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
