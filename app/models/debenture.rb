class Debenture < ApplicationRecord
  belongs_to :issuer
  has_many :debenture_market_data
end
