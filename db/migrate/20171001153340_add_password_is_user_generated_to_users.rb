class AddPasswordIsUserGeneratedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_is_user_generated, :boolean, default: true
    add_column :users, :last_sign_in_ip, :string
  end
end
