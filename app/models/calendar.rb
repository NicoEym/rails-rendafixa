class Calendar < ApplicationRecord
  has_many :debenture_market_data
  has_many :index_market_data
  has_many :curve_terms
end
