class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :password
      t.references :admin, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
