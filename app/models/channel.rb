class Channel < ActiveRecord::Base
  belongs_to :currency
  has_many :rules

  validates :name, presence: true

  accepts_nested_attributes_for :rules, allow_destroy: true
end
