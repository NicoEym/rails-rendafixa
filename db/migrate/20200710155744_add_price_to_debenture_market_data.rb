class AddPriceToDebentureMarketData < ActiveRecord::Migration[5.2]
  def change
    add_column :debenture_market_data, :price, :float
  end
end
