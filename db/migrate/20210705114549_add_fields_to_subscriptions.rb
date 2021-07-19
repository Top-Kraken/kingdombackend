class AddFieldsToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    change_column :subscriptions, :price, :decimal
    add_column :subscriptions, :second_price, :decimal
  end
end
