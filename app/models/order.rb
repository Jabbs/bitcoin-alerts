class Order < ActiveRecord::Base
  validates :client_id, presence: true, uniqueness: true
end
