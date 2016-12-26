class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :external_id
      t.integer :status, default: 0, null: false
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
