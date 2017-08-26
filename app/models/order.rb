class Order < ActiveRecord::Base
  belongs_to :scheme
  belongs_to :simulation
  belongs_to :quote
  belongs_to :strategy

  after_create :remove_coins_from_wallet, if: :sell?
  after_commit :add_coin_to_wallet, on: :create, if: :buy?

  def sell?
    self.side == "sell"
  end

  def buy?
    self.side == "buy"
  end

  def wallet
    if self.simulation_id.present?
      Wallet.find_by_name("simulation")
    else
      Wallet.find_by_name("trading")
    end
  end

  private

  def add_coin_to_wallet
    self.wallet.coins.create!(acquired_price: self.executed_value.to_f, currency: self.currency_pair.split("-")[0].downcase, order_id: self.id)
  end

  def remove_coins_from_wallet
    currency = self.currency_pair.split("-")[0].downcase
    coins = self.wallet.coins.send(currency)
    return unless coins.any?
    sold_price = self.executed_value.to_f / coins.count.to_f
    coins.update_all(sold_at: Time.zone.now, sold_price: sold_price)
  end
end
