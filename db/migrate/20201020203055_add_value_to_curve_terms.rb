class AddValueToCurveTerms < ActiveRecord::Migration[5.2]
  def change
    add_column :curve_terms, :value, :float
  end
end
