class AddIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :external_id
  end
end
