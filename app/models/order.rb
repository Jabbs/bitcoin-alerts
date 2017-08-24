class Order < ActiveRecord::Base
  belongs_to :scheme
  belongs_to :simulation
  belongs_to :quote
  belongs_to :strategy
end
