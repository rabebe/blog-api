class FixCommentsStatus < ActiveRecord::Migration[8.1]
  def change
    # Remove old status if it exists (string or broken enum)
    remove_column :comments, :status if column_exists?(:comments, :status)

    # Add integer status with default = pending
    add_column :comments, :status, :integer, default: 0, null: false
  end
end
