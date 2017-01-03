class PimpMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :image_url, :string
    add_index :metrics, :name
  end
end
