class CreateDebentures < ActiveRecord::Migration[5.2]
  def change
    create_table :debentures do |t|
      t.string :code
      t.references :issuer, foreign_key: true
      t.date :issuance_date
      t.date :maturity_date

      t.timestamps
    end
  end
end
