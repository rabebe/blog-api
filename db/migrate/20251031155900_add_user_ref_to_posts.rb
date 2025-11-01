class AddUserRefToPosts < ActiveRecord::Migration[7.1]
  def change
    # This line creates the foreign key column 'user_id' on the 'posts' table.
    add_reference :posts, :user, null: false, foreign_key: true
  end
end
