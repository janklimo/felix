class AddSuperadminToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :superadmin, :boolean, null: false, default: false
  end
end
