class AddEmailVerificationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :is_verified, :boolean, default: false
    add_column :users, :verification_token, :string
    add_index :users, :verification_token, unique: true
  end
end
