class AddFieldToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :twilio_number, :string
  end
end
