class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # Validations for Post attributes
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :body, presence: true

  # Access author
  def author_name
    user.username
  end
end
