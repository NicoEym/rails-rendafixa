class AddRateToDebentureMarketData < ActiveRecord::Migration[5.2]
  def change
    add_column :debenture_market_data, :bid_rate, :float
    add_column :debenture_market_data, :ask_rate, :float
  end
end
