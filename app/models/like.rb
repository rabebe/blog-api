class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  # Ensure one like per user per post
  validates :user_id, uniqueness: { scope: :post_id }
end
