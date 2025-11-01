class AddConstraintsToUsers < ActiveRecord::Migration[8.0]
  def change
    # Enforce non-null constraints
    change_column_null :users, :username, false
    change_column_null :users, :email, false
    change_column_null :users, :password_digest, false
  end
end
