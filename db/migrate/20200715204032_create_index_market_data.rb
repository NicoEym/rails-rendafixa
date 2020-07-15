class CreateIndexMarketData < ActiveRecord::Migration[5.2]
  def change
    create_table :index_market_data do |t|
      t.float :rate
      t.references :calendar, foreign_key: true
      t.references :index, foreign_key: true

      t.timestamps
    end
  end
end
