class ChangeLeads < ActiveRecord::Migration[6.1]
  def change
    rename_column :leads, :name, :first_name
    add_column :leads, :last_name, :string
    add_column :leads, :facebook, :string
    add_column :leads, :instagram, :string
    add_column :leads, :linkedin, :string
  end
end
