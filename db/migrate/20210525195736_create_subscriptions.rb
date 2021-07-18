class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.string :name, null: false
      t.integer :price, precision: 8, scale: 2
      t.string :detail, null: false

      t.timestamps
    end
  end
end
