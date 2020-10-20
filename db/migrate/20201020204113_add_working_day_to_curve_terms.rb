class AddWorkingDayToCurveTerms < ActiveRecord::Migration[5.2]
  def change
    add_column :curve_terms, :working_day, :integer
  end
end
