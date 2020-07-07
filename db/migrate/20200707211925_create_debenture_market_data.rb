class CreateDebentureMarketData < ActiveRecord::Migration[5.2]
  def change
    create_table :debenture_market_data do |t|
      t.float :rate
      t.float :credit_spread
      t.references :calendar, foreign_key: true
      t.references :debenture, foreign_key: true

      t.timestamps
    end
  end
end
