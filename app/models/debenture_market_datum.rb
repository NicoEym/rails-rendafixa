class DebentureMarketDatum < ApplicationRecord
  belongs_to :calendar
  belongs_to :debenture
end
