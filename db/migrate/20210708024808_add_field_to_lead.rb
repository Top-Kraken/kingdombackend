class AddFieldToLead < ActiveRecord::Migration[6.1]
  def change
    add_column :leads, :added_from, :string, default: 'lead_form'
  end
end
