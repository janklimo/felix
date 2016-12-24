class AddIndexToCompanies < ActiveRecord::Migration
  def change
    add_index :companies, :password
  end
end
