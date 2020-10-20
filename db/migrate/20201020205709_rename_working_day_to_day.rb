class RenameWorkingDayToDay < ActiveRecord::Migration[5.2]
  def change
    rename_column :curve_terms, :working_day, :day
  end
end
