class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :name, null: false, default: ""
      t.timestamps null: false
    end
  end
end
