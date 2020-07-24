class CreateCurves < ActiveRecord::Migration[5.2]
  def change
    create_table :curves do |t|
      t.string :name

      t.timestamps
    end
  end
end
