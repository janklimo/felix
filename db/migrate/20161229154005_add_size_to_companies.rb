class AddSizeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :size, :integer, null: false, default: 0
  end
end
