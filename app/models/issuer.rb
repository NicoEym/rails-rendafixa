class Issuer < ApplicationRecord
  has_many :debentures
  belongs_to :sector
end
