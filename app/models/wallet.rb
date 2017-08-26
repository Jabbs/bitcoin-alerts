class Wallet < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :coins, -> { where(sold_at: nil) }
end
