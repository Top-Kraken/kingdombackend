class AddFieldsToLeads < ActiveRecord::Migration[6.1]
  def change
    add_column :leads, :heat, :integer
    add_column :leads, :stage, :integer
  end
end
