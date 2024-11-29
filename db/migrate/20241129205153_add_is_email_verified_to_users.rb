class AddIsEmailVerifiedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :is_email_verified, :boolean, default: false
  end
end
