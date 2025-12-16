class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  # Validations
  validates :body, presence: true, length: { minimum: 1, maximum: 500 }

  # --- Manual status helpers  ---
  def pending?
    status == 0
  end

  def approved?
    status == 1
  end

  def rejected?
    status == 2
  end

  # Optional helpers for admin moderation
  def approve!
    update!(status: 1)
  end

  def reject!
    update!(status: 2)
  end
end
