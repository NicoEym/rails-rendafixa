class IndexMarketDatum < ApplicationRecord
  belongs_to :calendar
  belongs_to :index
end
