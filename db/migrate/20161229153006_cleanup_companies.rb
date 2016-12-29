class CleanupCompanies < ActiveRecord::Migration
  def change
    remove_column :companies, :latitude
    remove_column :companies, :longitude
    remove_index :companies, :password
    remove_column :companies, :password
  end
end
