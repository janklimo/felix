class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.string :title
      t.integer :value, null: false, default: 0
      t.references :question, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
