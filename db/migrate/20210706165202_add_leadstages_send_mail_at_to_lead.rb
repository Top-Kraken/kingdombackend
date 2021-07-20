class AddLeadstagesSendMailAtToLead < ActiveRecord::Migration[6.1]
  def change
  	add_column :leads, :prospecting_message_send_at, :datetime
  	add_column :leads, :contacted_message_send_at, :datetime
  	add_column :leads, :demo_message_send_at, :datetime
  	add_column :leads, :followup_message_send_at, :datetime
  	add_column :leads, :closing_message_send_at, :datetime
  	add_column :leads, :is_purchase_subscription, :boolean, default: false
  end
end
