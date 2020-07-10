class AddDaysToMaturityToDebentureMarketData < ActiveRecord::Migration[5.2]
  def change
    add_column :debenture_market_data, :days_to_maturity, :float
  end
end
