class CreateCurveTerms < ActiveRecord::Migration[5.2]
  def change
    create_table :curve_terms do |t|
      t.references :curve, foreign_key: true
      t.references :calendar, foreign_key: true

      t.timestamps
    end
  end
end
