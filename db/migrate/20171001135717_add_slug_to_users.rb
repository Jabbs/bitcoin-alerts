class AddSlugToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slug, :string
    add_column :users, :auth_token, :string
    add_index :users, :slug, unique: true
    add_index :users, :auth_token, unique: true
  end
end
