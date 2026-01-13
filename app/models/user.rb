class User < ApplicationRecord
  # --- Associations ---
  # 'dependent: :destroy' ensure that when a User is deleted
  # all associated posts are also deleted
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # --- Security: Password Hashing ---
  has_secure_password

  # --- Validations ---
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 25 }

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password,
            presence: true,
            length: { minimum: 6 },
            on: :create

  # --- Role / Authorization logic ---

  def admin?
    role.to_s.downcase == "admin" || role.to_i == 1
  end

  def user?
    role.to_s.downcase == "user" || role.to_i == 0
  end


  # --- Email Verification ---
  before_create :generate_verification_token

  def generate_verification_token
    self.verification_token = SecureRandom.uuid
  end

  # optional: force token regeneration later
  def generate_verification_token!
    update!(verification_token: SecureRandom.uuid)
  end

  def mark_as_verified!
    update(is_verified: true, verification_token: nil)
  end

  # Helper for testing / fixtures
  def self.digest(string)
    # Use minimum cost in tests for speed, while maintaining proper hashing logic.
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
