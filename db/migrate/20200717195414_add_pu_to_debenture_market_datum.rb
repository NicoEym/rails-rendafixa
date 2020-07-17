class AddPuToDebentureMarketDatum < ActiveRecord::Migration[5.2]
  def change
    add_column :debenture_market_data, :price_min, :float
    add_column :debenture_market_data, :price_max, :float
    add_column :debenture_market_data, :negociated_quantity, :integer
  end
end
