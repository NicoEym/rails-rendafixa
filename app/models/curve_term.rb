class CurveTerm < ApplicationRecord
  belongs_to :curve
  belongs_to :calendar
end
