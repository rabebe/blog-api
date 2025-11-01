class Post < ApplicationRecord
  belongs_to :user

  # Validations for robustness (ensures frontend sends data)
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :body, presence: true
end
