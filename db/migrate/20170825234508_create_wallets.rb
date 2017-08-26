class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.string :name

      t.timestamps null: false
    end

    Wallet.create!(name: "trading")
    Wallet.create!(name: "simulation")
    Wallet.create!(name: "holding")
  end
end
