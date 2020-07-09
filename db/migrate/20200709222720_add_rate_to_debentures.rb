class AddRateToDebentures < ActiveRecord::Migration[5.2]
  def change
    add_column :debentures, :rate_type, :string
    add_column :debentures, :index, :string
  end
end
