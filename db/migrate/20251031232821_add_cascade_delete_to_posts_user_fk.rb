class AddCascadeDeleteToPostsUserFk < ActiveRecord::Migration[8.0]
  def change
    # Remove the existing foreign key constraint
    remove_foreign_key :posts, :users

    # Add the foreign key back with the ON DELETE CASCADE option
    add_foreign_key :posts, :users, on_delete: :cascade
  end
end
