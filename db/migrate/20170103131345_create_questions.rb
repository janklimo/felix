class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title
      t.integer :row_order
      t.references :metric, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
