class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password_digest
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.boolean :verified
      t.string :verification_token
      t.datetime :verification_sent_at

      t.timestamps null: false
    end
    add_index :users, :email, unique: true
  end
end
